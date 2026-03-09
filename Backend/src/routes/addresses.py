from fastapi import APIRouter, HTTPException, Request, Depends
from pydantic import BaseModel
from typing import List, Optional
import uuid
import boto3
import os

router = APIRouter()

dynamodb = boto3.resource(
    'dynamodb',
    region_name=os.getenv("AWS_REGION", "us-east-1"),
    aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"),
    aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY")
)
ADDRESSES_TABLE = os.getenv("DYNAMO_ADDRESSES_TABLE", "SathiAI_Addresses")
table = dynamodb.Table(ADDRESSES_TABLE)

class AddressModel(BaseModel):
    email: str
    name: str
    phone: str
    street: str
    city: str
    state: str
    zipcode: str
    is_default: bool = False

@router.get("/")
async def get_addresses(email: str):
    try:
        response = table.query(
            KeyConditionExpression=boto3.dynamodb.conditions.Key('email').eq(email)
        )
        return response.get('Items', [])
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/")
async def add_address(address: AddressModel):
    address_id = str(uuid.uuid4())
    item = address.dict()
    item['id'] = address_id
    try:
        # If this is the default address, we should unset others
        if item['is_default']:
            # Find current default and unset it
            response = table.query(
                KeyConditionExpression=boto3.dynamodb.conditions.Key('email').eq(address.email)
            )
            for old_addr in response.get('Items', []):
                if old_addr.get('is_default'):
                    table.update_item(
                        Key={'email': address.email, 'id': old_addr['id']},
                        UpdateExpression="SET is_default = :val",
                        ExpressionAttributeValues={':val': False}
                    )
        table.put_item(Item=item)
        return {"message": "Address added", "id": address_id}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/{address_id}")
async def update_address(address_id: str, address: AddressModel):
    try:
        # Check if address exists
        response = table.get_item(Key={'email': address.email, 'id': address_id})
        if 'Item' not in response:
            raise HTTPException(status_code=404, detail="Address not found")
        
        item = address.dict()
        item['id'] = address_id
        
        if item['is_default']:
            # Unset other defaults
            all_addr = table.query(
                KeyConditionExpression=boto3.dynamodb.conditions.Key('email').eq(address.email)
            )
            for old_addr in all_addr.get('Items', []):
                if old_addr.get('is_default') and old_addr['id'] != address_id:
                    table.update_item(
                        Key={'email': address.email, 'id': old_addr['id']},
                        UpdateExpression="SET is_default = :val",
                        ExpressionAttributeValues={':val': False}
                    )
        table.put_item(Item=item)
        return {"message": "Address updated"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/{address_id}/delete")
async def delete_address(address_id: str, body: dict):
    email = body.get('email')
    if not email:
        raise HTTPException(status_code=400, detail="Missing email")
    try:
        table.delete_item(Key={'email': email, 'id': address_id})
        return {"message": "Address deleted"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/default/{address_id}")
async def set_default_address(address_id: str, body: dict):
    email = body.get('email')
    if not email:
        raise HTTPException(status_code=400, detail="Missing email")
    try:
        # Unset all
        all_addr = table.query(
            KeyConditionExpression=boto3.dynamodb.conditions.Key('email').eq(email)
        )
        for old_addr in all_addr.get('Items', []):
            table.update_item(
                Key={'email': email, 'id': old_addr['id']},
                UpdateExpression="SET is_default = :val",
                ExpressionAttributeValues={':val': old_addr['id'] == address_id}
            )
        return {"message": "Default address updated"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
