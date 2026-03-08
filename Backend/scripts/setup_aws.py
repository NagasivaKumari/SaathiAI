import boto3
import os
import time
from dotenv import load_dotenv

load_dotenv()

def create_tables():
    dynamodb = boto3.client(
        'dynamodb',
        region_name=os.getenv("AWS_REGION", "us-east-1"),
        aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"),
        aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY")
    )
    
    tables = [
        {
            'TableName': os.getenv("DYNAMO_USERS_TABLE", "SathiAI_Users"),
            'KeySchema': [{'AttributeName': 'email', 'KeyType': 'HASH'}],
            'AttributeDefinitions': [
                {'AttributeName': 'email', 'AttributeType': 'S'},
                {'AttributeName': 'level', 'AttributeType': 'N'}
            ],
            'GlobalSecondaryIndexes': [{
                'IndexName': 'LevelIndex',
                'KeySchema': [{'AttributeName': 'level', 'KeyType': 'HASH'}],
                'Projection': {'ProjectionType': 'ALL'},
                'ProvisionedThroughput': {'ReadCapacityUnits': 5, 'WriteCapacityUnits': 5}
            }],
            'ProvisionedThroughput': {'ReadCapacityUnits': 5, 'WriteCapacityUnits': 5}
        },
        {
            'TableName': os.getenv("DYNAMO_OTPS_TABLE", "SathiAI_OTPs"),
            'KeySchema': [{'AttributeName': 'email', 'KeyType': 'HASH'}],
            'AttributeDefinitions': [{'AttributeName': 'email', 'AttributeType': 'S'}],
            'ProvisionedThroughput': {'ReadCapacityUnits': 5, 'WriteCapacityUnits': 5}
        },
        {
            'TableName': os.getenv("DYNAMO_SCHEMES_TABLE", "SathiAI_Schemes"),
            'KeySchema': [{'AttributeName': 'id', 'KeyType': 'HASH'}],
            'AttributeDefinitions': [{'AttributeName': 'id', 'AttributeType': 'S'}],
            'ProvisionedThroughput': {'ReadCapacityUnits': 5, 'WriteCapacityUnits': 5}
        },
        {
            'TableName': os.getenv("DYNAMO_MARKET_TABLE", "SathiAI_MarketData"),
            'KeySchema': [{'AttributeName': 'id', 'KeyType': 'HASH'}],
            'AttributeDefinitions': [{'AttributeName': 'id', 'AttributeType': 'S'}],
            'ProvisionedThroughput': {'ReadCapacityUnits': 5, 'WriteCapacityUnits': 5}
        }
    ]
    
    existing_tables = dynamodb.list_tables()['TableNames']
    
    for table in tables:
        name = table['TableName']
        if name in existing_tables:
            print(f"Table {name} already exists. Skipping.")
            continue
            
        print(f"Creating table {name}...")
        try:
            dynamodb.create_table(**table)
            print(f"Successfully initiated creation of {name}.")
        except Exception as e:
            print(f"Error creating {name}: {e}")

if __name__ == "__main__":
    if os.getenv("AWS_ACCESS_KEY_ID") == "YOUR_ACCESS_KEY_ID":
        print("ERROR: Please update your .env file with real AWS credentials first!")
    else:
        create_tables()
        print("\nSetup complete! Please wait a minute for AWS to finalize the tables.")
