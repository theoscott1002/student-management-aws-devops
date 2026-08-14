import json
import boto3
import os

table = boto3.resource("dynamodb").Table(
    os.environ["TABLE_NAME"]
)

def lambda_handler(event, context):

    student_id = event['pathParameters']['id']

    response = table.get_item(
        Key={
            'studentId': student_id
        }
    )

    if 'Item' in response:
        return {
            "statusCode": 201,
            "body": json.dumps(response['Item'])
        }
    else:
        return {
            "statusCode": 404,
            "body": json.dumps({"message": "Student not found"})
        }