import boto3
import os
import time
from dotenv import load_dotenv

load_dotenv()

def seed_market():
    dynamodb = boto3.resource(
        'dynamodb',
        region_name=os.getenv("AWS_REGION", "us-east-1"),
        aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"),
        aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY")
    )
    
    table_name = os.getenv("DYNAMO_MARKET_TABLE", "SathiAI_MarketData")
    table = dynamodb.Table(table_name)
    
    market_items = [
        {"id": "m1", "crop": "Wheat", "price": "₹2,275/quintal", "trend": "up", "market": "Azadpur Mandi", "location": "Delhi"},
        {"id": "m2", "crop": "Potato", "price": "₹1,400/quintal", "trend": "stable", "market": "Vashi Mandi", "location": "Mumbai"},
        {"id": "m3", "crop": "Onion", "price": "₹3,500/quintal", "trend": "down", "market": "Lasalgaon Mandi", "location": "Nashik"},
        {"id": "m4", "crop": "Rice", "price": "₹4,100/quintal", "trend": "up", "market": "Burdwan Mandi", "location": "West Bengal"}
    ]

    print(f"Seeding {len(market_items)} items into {table_name}...")
    with table.batch_writer() as batch:
        for item in market_items:
            item['last_updated'] = str(time.time())
            batch.put_item(Item=item)

    print("Seeding complete!")

if __name__ == "__main__":
    seed_market()
