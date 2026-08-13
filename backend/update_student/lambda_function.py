import json
import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('Students')

def lambda_handler(event, context):

    student_id = event['pathParameters']['id']
    body = json.loads(event['body'])

    response = table.update_item(
        Key={'studentId': student_id},
        UpdateExpression="""
            SET #n = :name,
                department = :dept,
                #lvl = :level,
                email = :email
        """,
        ExpressionAttributeNames={
            '#n': 'name',
            '#lvl': 'level'
        },
        ExpressionAttributeValues={
            ':name': body['name'],
            ':dept': body['department'],
            ':level': body['level'],
            ':email': body['email']
        },
        ReturnValues="ALL_NEW"
    )

    return {
        "statusCode": 200,
        "body": json.dumps(response['Attributes'])
    }