from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
import os
from src.aws_db import db_service

router = APIRouter()

class DeleteAccountModel(BaseModel):
    email: str

@router.get("/terms")
async def get_terms():
    return {"text": "1. Acceptance of Terms\nBy using SathiAI, you agree to these terms...\n2. User Responsibilities\nDo not misuse the application."}

@router.get("/privacy")
async def get_privacy():
    return {"text": "1. Data Collection\nWe collect your phone number and farming preferences to provide tailored schemes...\n2. Data Sharing\nWe do not share data with third parties."}

@router.post("/delete-account")
async def delete_account(payload: DeleteAccountModel):
    # Retrieve user to ensure they exist
    user = db_service.get_user_by_email(payload.email)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
        
    try:
        # Delete user from DynamoDB users table
        db_service.users_table.delete_item(Key={'email': payload.email})
        # Delete OTPs if any
        db_service.delete_otp(payload.email)
        return {"message": "Account deleted successfully. We are sorry to see you go."}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
