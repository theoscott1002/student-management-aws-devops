import json
import os
import boto3
import uuid

#Ceating Students

table = boto3.resource("dynamodb").Table(
    os.environ["TABLE_NAME"]
)

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
        "statusCode": 201,
        "body": json.dumps({
            "message": "Student created",
            "student": student
        })
    }