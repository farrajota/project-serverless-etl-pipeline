import os
import json
import boto3
import pandas as pd

bucket_source_name = os.environ["S3_BUCKET_SOURCE"]
bucket_destination_name = os.environ["S3_BUCKET_DEST"]
dynamodb_table_name = os.environ["DYNAMODB_TABLE"]

s3 = boto3.resource('s3')
bucket_source = s3.Bucket(bucket_source_name)
bucket_dest = s3.Bucket(bucket_destination_name)

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(dynamodb_table_name)


def lambda_handler(event, context):
    # retrieve bucket name and file_key from the S3 event
    bucket_name = event['Records'][0]['s3']['bucket']['name']
    file_key = event['Records'][0]['s3']['object']['key']

    tmp_filename = '/tmp/tmp_file'
    response = bucket_source.download_file(file_key, tmp_filename)

    # parse data from file to a dict
    with open(tmp_filename, 'r') as f:
        obj_data = f.read()
    data = "[" + obj_data.replace("}{", "},{") + "]"

    # load as a Pandas DataFrame
    df = pd.DataFrame(json.loads(data))

    # convert to parquet and save to disk
    filename_parquet = os.path.basename(file_key).split(".")[0] + ".parquet"
    df.to_parquet(f"/tmp/{filename_parquet}", engine="pyarrow", compression="GZIP")

    # upload file to another s3 bucket
    s3_path_filename = os.path.join(os.path.dirname(file_key), filename_parquet)
    response = s3.Bucket(bucket_destination_name).upload_file(f"/tmp/{filename_parquet}", s3_path_filename)

    # remove original file from source bucket
    obj = bucket_source.Object(file_key)
    obj.delete()

    # compute clicks per client per gender
    clicks = df.groupby(["clientid", "pageGender"]).count()

    # update dynamodb with new clicks
    for client_id in clicks.index.levels[0]:
        # client data
        last_gender = df[df["clientid"] == client_id].sort_values(by="timestamp", ascending=False).head(1)["pageGender"].iloc[0]

        try:
            top_gender_male_count = int(clicks.loc[client_id].loc["M", "timestamp"])
        except KeyError:
            top_gender_male_count = 0

        try:
            top_gender_female_count = int(clicks.loc[client_id].loc["F", "timestamp"])
        except KeyError:
            top_gender_female_count = 0

        # get item from the dynamodb table
        response = get_item_dynamodb(client_id)

        # update item data
        if "Item" in response:
            new_data = response["Item"]
            new_data["last_gender"] = last_gender
            new_data["top_gender_counter_m"] += top_gender_male_count
            new_data["top_gender_counter_f"] += top_gender_female_count
            new_data["gender"] = compute_gender(last_gender=new_data["last_gender"],
                                                top_gender_male=new_data["top_gender_counter_m"],
                                                top_gender_female=new_data["top_gender_counter_f"],
                                                top_gender_7_days=new_data["top_gender_last_7_days"])
        else:
            # new item
            if top_gender_male_count > top_gender_female_count:
                gender = 'M'
            else:
                gender = 'F'
            new_data = {
                "clientid": client_id,
                "last_gender": last_gender,
                "top_gender_counter_m": top_gender_male_count,
                "top_gender_counter_f": top_gender_female_count,
                "top_gender_last_7_days": gender,
                "gender": gender,
            }

        response = put_item_dynamodb(new_data)

    return {
        'statusCode': 200,
        'body': json.dumps('Successfully processed Kinesis Firehose stream data')
    }


def get_item_dynamodb(client_id):
    """Retrieves an item from dynamodb table."""
    response = table.get_item(Key={"clientid": client_id})
    return response


def put_item_dynamodb(data):
    """Puts data of an item to dynamodb table."""
    response = table.put_item(Item=data)
    return response


def compute_gender(last_gender: str,
                   top_gender_male: int,
                   top_gender_female: int,
                   top_gender_7_days: str):
    """Computes the gender type of a visitor using a majority voting rule."""
    def majority_voting(lst):
        return max(set(lst), key=lst.count)

    if top_gender_male > top_gender_female:
        top_gender = 'M'
    else:
        top_gender = 'F'

    return majority_voting([last_gender, top_gender, top_gender_7_days])
