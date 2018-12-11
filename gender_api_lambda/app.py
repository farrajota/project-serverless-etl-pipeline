import os
import boto3
import json

dynamodb_table_name = os.environ["DYNAMODB_TABLE"]
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(dynamodb_table_name)


def lambda_handler(event, context):
    """Retrieve gender information of a client id."""
    client_id = event["pathParameters"]["clientid"]
    response = get_item_dynamodb(client_id)
    if "Item" in response:
        data = response["Item"]
        output = {"clientid": client_id, "gender": data["gender"]}
    else:
        output = {"clientid": client_id, "gender": "Null"}
    return {
        "statusCode": 200,
        "body": json.dumps(output),
    }


def get_item_dynamodb(client_id):
    response = table.get_item(Key={"clientid": client_id})
    return response