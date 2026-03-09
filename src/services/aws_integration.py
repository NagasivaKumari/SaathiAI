import os
import boto3
from botocore.exceptions import ClientError

# DynamoDB setup
DYNAMODB_TABLE = os.getenv('DYNAMODB_TABLE', 'SaathiAIUsers')
dynamodb = boto3.resource('dynamodb', region_name=os.getenv('AWS_REGION', 'us-east-1'))
users_table = dynamodb.Table(DYNAMODB_TABLE)

# SES setup
SES_SENDER = os.getenv('SES_SENDER_EMAIL')
ses_client = boto3.client('ses', region_name=os.getenv('AWS_REGION', 'us-east-1'))

def send_otp_email(to_email, otp):
    subject = 'Your OTP Code'
    body = f'Your OTP code is: {otp}'
    try:
        response = ses_client.send_email(
            Source=SES_SENDER,
            Destination={'ToAddresses': [to_email]},
            Message={
                'Subject': {'Data': subject},
                'Body': {'Text': {'Data': body}}
            }
        )
        return response
    except ClientError as e:
        print(f"SES send_email failed: {e}")
        return None

def get_user_by_email(email):
    try:
        response = users_table.get_item(Key={'email': email})
        return response.get('Item')
    except ClientError as e:
        print(f"DynamoDB get_item failed: {e}")
        return None

def create_user(user_data):
    try:
        users_table.put_item(Item=user_data)
        return True
    except ClientError as e:
        print(f"DynamoDB put_item failed: {e}")
        return False

def update_user(email, update_data):
    # Simplified update logic
    try:
        users_table.update_item(
            Key={'email': email},
            AttributeUpdates={k: {'Value': v, 'Action': 'PUT'} for k, v in update_data.items()}
        )
        return True
    except ClientError as e:
        print(f"DynamoDB update_item failed: {e}")
        return False
