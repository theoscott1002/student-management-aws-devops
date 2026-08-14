import json
import boto3
import os

table = boto3.resource("dynamodb").Table(
    os.environ["TABLE_NAME"]
)

def lambda_handler(event, context):

    student_id = event['pathParameters']['id']

    table.delete_item(
        Key={'studentId': student_id}
    )

    return {
        "statusCode": 201,
        "body": json.dumps({"message": "Student deleted"})
    }