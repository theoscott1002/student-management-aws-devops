import json
import boto3
import os

table = boto3.resource("dynamodb").Table(
    os.environ["TABLE_NAME"]
)

def lambda_handler(event, context):

    response = table.scan()

    return {
        "statusCode": 201,
        "body": json.dumps(response['Items'])
    }