import json
import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('Students')

def lambda_handler(event, context):

    student_id = event['pathParameters']['id']

    table.delete_item(
        Key={'studentId': student_id}
    )

    return {
        "statusCode": 200,
        "body": json.dumps({"message": "Student deleted"})
    }