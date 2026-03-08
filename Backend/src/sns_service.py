import boto3
import os
from botocore.exceptions import ClientError

class SNSService:
    def __init__(self):
        self.sns = boto3.client(
            'sns',
            region_name=os.getenv("AWS_REGION", "us-east-1"),
            aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"),
            aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY")
        )

    def send_sms(self, phone_number, message):
        try:
            self.sns.publish(PhoneNumber=phone_number, Message=message)
            return True
        except ClientError as e:
            print(f"SNS SMS Error: {e}")
            return False

sns_service = SNSService()
