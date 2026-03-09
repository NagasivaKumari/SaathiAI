import uuid
import time
from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel, EmailStr, Field
from src.aws_db import db_service

router = APIRouter()

# Pydantic models
class ForgotPasswordRequest(BaseModel):
    email: EmailStr = Field(..., description="User email for password reset")

class ResetPasswordRequest(BaseModel):
    token: str = Field(..., description="Reset token received via email")
    new_password: str = Field(..., min_length=8, description="New password")

# DynamoDB table name (environment variable should be set in serverless.yml)
TABLE_NAME = "SathiAI_PasswordResetTokens"

@router.post("/auth/forgot-password")
async def forgot_password(req: ForgotPasswordRequest):
    if not db_service.dynamodb:
        raise HTTPException(status_code=500, detail="Database connection failed")
    table = db_service.dynamodb.Table(TABLE_NAME)
    # generate a token (UUID) and store with TTL (15 minutes)
    token = str(uuid.uuid4())
    ttl = int(time.time()) + 15 * 60
    item = {
        "email": req.email,
        "token": token,
        "expires_at": ttl,
    }
    table.put_item(Item=item)
    # TODO: send email with token (e.g., via SES or SNS). For now we just return token for testing.
    return {"message": "Password reset token generated", "token": token}

@router.put("/auth/reset-password")
async def reset_password(req: ResetPasswordRequest):
    if not db_service.dynamodb:
        raise HTTPException(status_code=500, detail="Database connection failed")
    token_table = db_service.dynamodb.Table(TABLE_NAME)
    # Look up token - we need to scan or query a GSI here if we only have token.
    # For now, wait, the original code queried an IndexName="token-index".
    # We will assume that GSI exists or do a scan (not ideal but safe for demo fixing)
    try:
        resp = token_table.query(
            IndexName="token-index",
            KeyConditionExpression=Key("token").eq(req.token)
        )
    except Exception:
        # Fallback to scan if index doesn't exist
        from boto3.dynamodb.conditions import Attr
        resp = token_table.scan(FilterExpression=Attr("token").eq(req.token))
        
    if not resp.get("Items"):
        raise HTTPException(status_code=400, detail="Invalid or expired token")
    item = resp["Items"][0]
    
    # Verify expiry
    if int(time.time()) > item["expires_at"]:
        raise HTTPException(status_code=400, detail="Token has expired")
        
    # Update user password in Users table
    import bcrypt
    users_table = db_service.users_table
    hashed = bcrypt.hashpw(req.new_password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
    users_table.update_item(
        Key={"email": item["email"]},
        UpdateExpression="SET password = :ph",
        ExpressionAttributeValues={":ph": hashed},  
    )
    
    # Delete token after use
    token_table.delete_item(Key={"email": item["email"], "token": req.token})
    return {"message": "Password has been reset successfully"}
