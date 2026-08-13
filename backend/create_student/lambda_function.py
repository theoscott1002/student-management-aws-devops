import json
import boto3
import uuid

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('Students')

def lambda_handler(event, context):

    body = json.loads(event.get("body", "{}"))

    student = {
        "studentId": str(uuid.uuid4()),
        "name": body.get("name"),
        "department": body.get("department"),
        "level": body.get("level"),
        "email": body.get("email")
    }

    table.put_item(Item=student)

    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": "Student created",
            "student": student
        })
    }