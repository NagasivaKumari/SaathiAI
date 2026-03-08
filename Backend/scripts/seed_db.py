import boto3
import os
import json
from dotenv import load_dotenv

load_dotenv()

def seed_schemes():
    dynamodb = boto3.resource(
        'dynamodb',
        region_name=os.getenv("AWS_REGION", "us-east-1"),
        aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"),
        aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY")
    )
    
    table_name = os.getenv("DYNAMO_SCHEMES_TABLE", "SathiAI_Schemes")
    table = dynamodb.Table(table_name)
    
    schemes_file = "d:/SaathiAI/Schemes/govt_schemes.json"
    if not os.path.exists(schemes_file):
        print(f"Error: {schemes_file} not found")
        return

    with open(schemes_file, 'r', encoding='utf-8') as f:
        data = json.load(f)
        schemes = data.get('schemes', [])

    print(f"Seeding {len(schemes)} schemes into {table_name}...")
    seen_ids = set()
    with table.batch_writer() as batch:
        for scheme in schemes:
            if isinstance(scheme, str): continue # Safety check
            
            # Use provided ID or generate one
            item_id = scheme.get('id') or str(abs(hash(scheme.get('name', scheme.get('title', '')))))
            
            if item_id in seen_ids:
                print(f"Skipping duplicate ID: {item_id}")
                continue
            seen_ids.add(item_id)

            # Clean data for DynamoDB (remove empty strings, ensure types)
            item = {k: v for k, v in scheme.items() if v != "" and v is not None}
            item['id'] = item_id
            batch.put_item(Item=item)

    print("Seeding complete!")

if __name__ == "__main__":
    seed_schemes()
