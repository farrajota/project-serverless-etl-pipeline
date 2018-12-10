import os
import boto3
import datetime
import json
import pandas as pd
import pytz


temp_filename = '/tmp/temp_file.parquet'
prefix = os.environ["FIREHOSE_PREFIX"]
bucket_source_name = os.environ["S3_BUCKET_SOURCE"]
dynamodb_table_name = os.environ["DYNAMODB_TABLE"]

s3 = boto3.resource('s3')
bucket = s3.Bucket(bucket_source_name)

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(dynamodb_table_name)


def lambda_handler(event, context):
    # get current datetime
    current_datetime = datetime.datetime.now(tz=pytz.timezone('Europe/Lisbon'))

    # get previous day info (year + month + day)
    previous_datetime = current_datetime - datetime.timedelta(days=1)  # subtract a day
    year = previous_datetime.year
    month = previous_datetime.month
    day = previous_datetime.day

    # compute all hits in a day per client
    daily_hits = get_daily_hits(bucket, year, month, day)

    # save daily hits to file in parquet format
    filename_parquet = f"daily-hits-{year}-{month}-{day}.parquet"
    daily_hits.to_parquet(f"/tmp/{filename_parquet}", engine="pyarrow", compression="GZIP")

    # upload daily hits to S3
    filename_s3 = f"{year}/{month}/{day}/{filename_parquet}"
    if prefix:
        filename_s3 = f"{prefix}/{filename_s3}"
    response = bucket.upload_file(f"/tmp/{filename_parquet}", filename_s3)

    # update gender info in the last 7 days
    top_gender_last_7_days = get_top_gender_previous_7_days(daily_hits, current_datetime)

    # update dynamodb
    for client_id in top_gender_last_7_days.index:
        # get visitor's item from dynamodb
        response = get_item_dynamodb(client_id)

        data = response["Item"]
        data["top_gender_last_7_days"] = top_gender_last_7_days[client_id]

        # put data back to dynamodb
        response = put_item_dynamodb(data)

    return {
        'statusCode': 200,
        'body': json.dumps('Successfully processed top gender in the last 7 days')
    }


def get_daily_hits(bucket, year, month, day):
    """Computes visitors page hits in a single day."""
    # get an object iterator for a specific path in the
    # bucket to filter only the files for that day
    object_prefix = f'{year}/{month}/{day}'
    if prefix:
        object_prefix = f'{prefix}/{object_prefix}'
    object_summary_iterator = bucket.objects.filter(
        Prefix=object_prefix
    )

    # get all objects keys (filenames)
    for obj in object_summary_iterator.all():
        # Get object key
        filename = obj.key

        daily_hits = []
        if filename.endswith('.parquet'):
            # Download file from S3
            response = bucket.download_file(filename, temp_filename)

            # Load file as a DataFrame
            df = pd.read_parquet(temp_filename)

            # compute page hits per gender per client
            hits = df.groupby(["clientid", "pageGender"]).count()

            # Update hits per client in DataFrame
            if daily_hits:
                hits = df.groupby(["clientid", "pageGender"]).count()
                merge_df = pd.concat([daily_hits.reset_index(), hits.reset_index()])
                daily_hits = merge_df.groupby(["clientid", "pageGender"]).count()
            else:
                daily_hits = hits

    return daily_hits


def get_top_gender_previous_7_days(daily_hits, current_datetime):
    """Computes visitors top page hits in the last 7 days."""
    top_hits_7_days = daily_hits

    # get previous day info (year + month + day)
    for delta in range(2, 7+1):
        previous_datetime = current_datetime - datetime.timedelta(days=delta)  # subtract a day
        year = previous_datetime.year
        month = previous_datetime.month
        day = previous_datetime.day

        # download file from S3
        filename_s3 = f"{year}/{month}/{day}/daily-hits-{year}-{month}-{day}.parquet"
        if prefix:
            filename_s3 = f"{prefix}/{filename_s3}"
        tmp_filename = f"/tmp/{os.path.basename(filename_s3)}"

        if object_exists_in_s3(tmp_filename):
            response = bucket.download_file(filename_s3, tmp_filename)

            # load file to a pandas DataFrame
            daily_hit_prev = pd.read_parquet(tmp_filename)

            # merge daily hits
            merge_df = pd.concat([top_hits_7_days.reset_index(), daily_hit_prev.reset_index()])
            top_hits_7_days = merge_df.groupby(["clientid", "pageGender"]).count()

    # compute top genders for each clientid
    top_gender_7_days = top_hits_7_days.reset_index().groupby(["clientid"]).max()["pageGender"]
    return top_gender_7_days


def get_item_dynamodb(client_id):
    """Retrieves an item from dynamodb table."""
    response = table.get_item(Key={"clientid": client_id})
    return response


def put_item_dynamodb(data):
    """Puts data of an item to dynamodb table."""
    response = table.put_item(Item=data)
    return response


def object_exists_in_s3(filename):
    """Checks if an object exists in S3."""
    object_summary_iterator = bucket.objects.filter(
        Prefix=filename
    )
    return any(list(object_summary_iterator.all()))
