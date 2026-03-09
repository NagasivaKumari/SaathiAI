from typing import Optional, Dict, Any
def get_user_by_username(self, username: str) -> Optional[Dict[str, Any]]:
    try:
        response = self.users_table.scan(
            FilterExpression='username = :username',
            ExpressionAttributeValues={':username': username}
        )
        items = response.get('Items', [])
        return items[0] if items else None
    except Exception:
        return None

def get_user_by_phone(self, phone: str) -> Optional[Dict[str, Any]]:
    try:
        response = self.users_table.scan(
            FilterExpression='phone = :phone',
            ExpressionAttributeValues={':phone': phone}
        )
        items = response.get('Items', [])
        return items[0] if items else None
    except Exception:
        return None
import boto3
import os
import time
from typing import List, Dict, Any, Optional
from botocore.exceptions import ClientError, NoCredentialsError
from dotenv import load_dotenv

load_dotenv()


class DynamoDBService:
    def delete_all_users(self):
        """Delete all users from the users table. Use for admin/cleanup only!"""
        try:
            scan = self.users_table.scan()
            with self.users_table.batch_writer() as batch:
                for item in scan.get('Items', []):
                    batch.delete_item(Key={"email": item["email"]})
            print("All users deleted from DynamoDB users table.")
        except Exception as e:
            print(f"Error deleting all users: {e}")

    def __init__(self):
        try:
            # On Lambda the IAM execution role provides credentials automatically.
            # When running locally, boto3 picks them up from env vars / .env.
            access_key = os.getenv("AWS_ACCESS_KEY_ID")
            secret_key = os.getenv("AWS_SECRET_ACCESS_KEY")

            if access_key and secret_key and "YOUR" not in access_key:
                # Local dev: explicit credentials
                self.dynamodb = boto3.resource(
                    'dynamodb',
                    region_name=os.getenv("AWS_REGION", "us-east-1"),
                    aws_access_key_id=access_key,
                    aws_secret_access_key=secret_key,
                )
            else:
                # Lambda / EC2: use IAM role (no explicit keys needed)
                self.dynamodb = boto3.resource(
                    'dynamodb',
                    region_name=os.getenv("AWS_REGION", "us-east-1"),
                )

            self.users_table = self.dynamodb.Table(os.getenv("DYNAMO_USERS_TABLE", "SathiAI_Users"))
            self.schemes_table = self.dynamodb.Table(os.getenv("DYNAMO_SCHEMES_TABLE", "SathiAI_Schemes"))
            self.otps_table = self.dynamodb.Table(os.getenv("DYNAMO_OTPS_TABLE", "SathiAI_OTPs"))
            print("✅ DynamoDB connected successfully")
        except Exception as e:
            print(f"❌ AWS Connection Failed: {e}")
            self.dynamodb = None

    def get_user_by_email(self, email: str) -> Optional[Dict[str, Any]]:
        try:
            response = self.users_table.get_item(Key={'email': email})
            return response.get('Item')
        except Exception:
            return None

    def create_user(self, user_data: Dict[str, Any]):
        try:
            user_data['created_at'] = str(time.time())
            user_data['points'] = user_data.get('points', 0)
            user_data['level'] = user_data.get('level', 1)
            self.users_table.put_item(Item=user_data)
        except Exception as e:
            print(f"DynamoDB Error: {e}")

    def update_user_gamification(self, email: str, points: int, level: int):
        try:
            self.users_table.update_item(
                Key={'email': email},
                UpdateExpression="SET points = points + :p, #lvl = :l",
                ExpressionAttributeNames={'#lvl': 'level'},
                ExpressionAttributeValues={':p': points, ':l': level}
            )
        except Exception as e:
            print(f"DynamoDB Error: {e}")

    def save_otp(self, email: str, otp: str):
        try:
            self.otps_table.put_item(Item={
                'email': email,
                'otp': otp,
                'expires_at': int(time.time()) + 600
            })
        except Exception as e:
            print(f"DynamoDB Error: {e}")

    def verify_otp(self, email: str, otp: str) -> bool:
        try:
            response = self.otps_table.get_item(Key={'email': email})
            item = response.get('Item')
            if item and item.get('otp') == otp:
                if item.get('expires_at', 0) > time.time():
                    return True
            return False
        except Exception:
            return False

    def delete_otp(self, email: str):
        try:
            self.otps_table.delete_item(Key={'email': email})
        except Exception:
            pass

    def get_all_schemes(self) -> List[Dict[str, Any]]:
        if not self.dynamodb:
            return []
        try:
            response = self.schemes_table.scan()
            return response.get('Items', [])
        except Exception:
            return []

    def get_scheme_by_id(self, scheme_id: str) -> Optional[Dict[str, Any]]:
        """Fetch a single scheme from DynamoDB by its ID.
        Returns the scheme dict or None if not found.
        """
        if not self.dynamodb:
            return None
        try:
            response = self.schemes_table.get_item(Key={'id': scheme_id})
            return response.get('Item')
        except Exception:
            return None

    def get_market_data(self) -> List[Dict[str, Any]]:
        if not self.dynamodb:
            return []
        try:
            table = self.dynamodb.Table(os.getenv("DYNAMO_MARKET_TABLE", "SathiAI_MarketData"))
            response = table.scan()
            return response.get('Items', [])
        except Exception:
            return []

    def save_market_item(self, item: Dict[str, Any]):
        try:
            table = self.dynamodb.Table(os.getenv("DYNAMO_MARKET_TABLE", "SathiAI_MarketData"))
            table.put_item(Item=item)
        except Exception as e:
            print(f"DynamoDB Error: {e}")

db_service = DynamoDBService()
