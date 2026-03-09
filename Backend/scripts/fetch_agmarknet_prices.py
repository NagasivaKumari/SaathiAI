import requests
import csv
import io
import boto3
import os
from datetime import datetime

# Example Agmarknet daily report URL (change as needed)
CSV_URL = "https://agmarknet.gov.in/downloadfile.aspx?filename=DailyReport_English.csv"

def download_csv(url=CSV_URL):
    resp = requests.get(url)
    resp.raise_for_status()
    return resp.content

def parse_csv(csv_bytes):
    csvfile = io.StringIO(csv_bytes.decode('utf-8'))
    reader = csv.DictReader(csvfile)
    prices = []
    for row in reader:
        prices.append({
            'date': row.get('Arrival_Date') or row.get('Date'),
            'market': row.get('Market'),
            'state': row.get('State'),
            'commodity': row.get('Commodity'),
            'variety': row.get('Variety'),
            'min_price': row.get('Min_Price'),
            'max_price': row.get('Max_Price'),
            'modal_price': row.get('Modal_Price'),
        })
    return prices

def upload_to_s3(prices, bucket, key):
    import json
    s3 = boto3.client(
        's3',
        aws_access_key_id=os.getenv('AWS_ACCESS_KEY_ID'),
        aws_secret_access_key=os.getenv('AWS_SECRET_ACCESS_KEY'),
        region_name=os.getenv('AWS_REGION', 'ap-south-1'),
    )
    s3.put_object(
        Bucket=bucket,
        Key=key,
        Body=json.dumps(prices),
        ContentType='application/json',
    )
    print(f"Uploaded {len(prices)} records to s3://{bucket}/{key}")

if __name__ == "__main__":
    print(f"Downloading Agmarknet CSV for {datetime.now().date()}...")
    csv_bytes = download_csv()
    prices = parse_csv(csv_bytes)
    print(f"Parsed {len(prices)} records. Sample:")
    for p in prices[:5]:
        print(p)
    # Overwrite a single S3 object (no file accumulation)
    S3_BUCKET = os.getenv('S3_BUCKET', 'sathiai-assets')
    S3_KEY = 'market/latest_prices.json'
    upload_to_s3(prices, S3_BUCKET, S3_KEY)
