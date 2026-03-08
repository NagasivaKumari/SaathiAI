import boto3
import os
from dotenv import load_dotenv

load_dotenv()

def check_dynamodb():
    dynamodb = boto3.resource(
        'dynamodb',
        region_name=os.getenv("AWS_REGION", "us-east-1"),
        aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"),
        aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY")
    )
    
    tables = [
        os.getenv("DYNAMO_USERS_TABLE", "SathiAI_Users"),
        os.getenv("DYNAMO_SCHEMES_TABLE", "SathiAI_Schemes"),
        os.getenv("DYNAMO_OTPS_TABLE", "SathiAI_OTPs")
    ]
    
    client = boto3.client(
        'dynamodb',
        region_name=os.getenv("AWS_REGION", "us-east-1"),
        aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"),
        aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY")
    )
    
    existing_tables = client.list_tables()['TableNames']
    print(f"Existing tables: {existing_tables}")
    
    for table_name in tables:
        if table_name not in existing_tables:
            print(f"MISSING TABLE: {table_name}")
        else:
            print(f"Table found: {table_name}")

if __name__ == "__main__":
    check_dynamodb()
