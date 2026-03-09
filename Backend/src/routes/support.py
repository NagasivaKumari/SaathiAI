from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
import uuid
import boto3
import os
import time

router = APIRouter()

dynamodb = boto3.resource(
    'dynamodb',
    region_name=os.getenv("AWS_REGION", "us-east-1"),
    aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"),
    aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY")
)
SUPPORT_TABLE = os.getenv("DYNAMO_SUPPORT_TABLE", "SathiAI_SupportTickets")
table = dynamodb.Table(SUPPORT_TABLE)

class ContactModel(BaseModel):
    email: str
    message: str
    subject: str = "General Inquiry"

class ReportModel(BaseModel):
    email: str
    issue_type: str
    description: str

@router.post("/contact")
async def contact_support(payload: ContactModel):
    ticket_id = str(uuid.uuid4())
    item = payload.dict()
    item['id'] = ticket_id
    item['status'] = 'open'
    item['created_at'] = int(time.time())
    item['type'] = 'contact'
    try:
        table.put_item(Item=item)
        return {"message": "Support request received.", "ticket_id": ticket_id}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/report")
async def report_problem(payload: ReportModel):
    ticket_id = str(uuid.uuid4())
    item = payload.dict()
    item['id'] = ticket_id
    item['status'] = 'open'
    item['created_at'] = int(time.time())
    item['type'] = 'report'
    try:
        table.put_item(Item=item)
        return {"message": "Problem reported successfully.", "ticket_id": ticket_id}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/faq")
async def get_faq():
    # Typically stored in S3 or DynamoDB, but returning static demo data here
    return [
        {"question": "How do I verify my farming profile?", "answer": "You can verify your profile using the OTP sent to your Aadhaar-linked mobile number."},
        {"question": "How to change app language?", "answer": "Go to Settings -> Language and choose your preferred language."},
        {"question": "Is SathiAI free?", "answer": "Yes, basic features are free for all registered users."}
    ]
