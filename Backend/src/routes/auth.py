from src.device_fingerprint import get_device_fingerprint

from fastapi import APIRouter, HTTPException, Body, Response, Request
from pydantic import BaseModel, EmailStr
# ...existing code...


# ...existing code...

router = APIRouter()

# Resend OTP endpoint
class ResendOtpRequest(BaseModel):
    email: EmailStr

@router.post("/resend-otp")
async def resend_otp(request: ResendOtpRequest, req: Request):
    check_rate_limit(req)
    fingerprint = get_device_fingerprint(req)
    print(f"OTP resend requested from device: {fingerprint}")
    otp = str(random.randint(100000, 999999))
    db_service.save_otp(request.email, otp)
    message_id = ses_service.send_otp_email(request.email, otp)
    if not message_id:
        print(f"DEBUG: OTP {otp} for {request.email} (SES failed or not setup)")
        return {"message": "OTP generated (Trial Mode)", "otp": otp}
    return {"message": "OTP resent successfully to your email"}
from src.device_fingerprint import get_device_fingerprint

from fastapi import APIRouter, HTTPException, Body, Response, Request
from pydantic import BaseModel, EmailStr
import random
import datetime
import jwt
import secrets
import bcrypt
import os
from typing import Optional
from src.aws_db import db_service
from src.ses_service import ses_service
from src.rate_limit import check_rate_limit


router = APIRouter()

# In-memory refresh token store (for demo; use DynamoDB/Redis in prod)
refresh_tokens = {}

ACCESS_TOKEN_EXPIRE_MINUTES = 15
REFRESH_TOKEN_EXPIRE_DAYS = 30
JWT_SECRET = os.getenv("JWT_SECRET", "sathiai-secret-key")

class SendOtpRequest(BaseModel):
    email: EmailStr
    username: Optional[str] = None
    phone: Optional[str] = None
    isSignup: bool = False

class VerifyOtpRequest(BaseModel):
    email: EmailStr
    otp: str
    name: Optional[str] = None
    username: Optional[str] = None
    phone: Optional[str] = None
    password: Optional[str] = None
    isSignup: bool = False

class LoginRequest(BaseModel):
    email: EmailStr
    password: str

@router.post("/send-otp")
async def send_otp(request: SendOtpRequest, req: Request):
    check_rate_limit(req)
    fingerprint = get_device_fingerprint(req)
    print(f"OTP requested from device: {fingerprint}")
    otp = str(random.randint(100000, 999999))

    if request.isSignup:
        # Check uniqueness for email, username, phone
        if db_service.get_user_by_email(request.email):
            raise HTTPException(status_code=400, detail="Email already registered")
        if request.username and db_service.get_user_by_username(request.username):
            raise HTTPException(status_code=400, detail="Username already taken")
        if request.phone and db_service.get_user_by_phone(request.phone):
            raise HTTPException(status_code=400, detail="Phone number already registered")

    db_service.save_otp(request.email, otp)

    # Send via Amazon SES
    message_id = ses_service.send_otp_email(request.email, otp)

    if not message_id:
        # Fallback for console logging if SES fails (e.g. unverified email in sandbox)
        print(f"DEBUG: OTP {otp} for {request.email} (SES failed or not setup)")
        return {"message": "OTP generated (Trial Mode)", "otp": otp} # Allow dev to see it if SES is pending

    return {"message": "OTP sent successfully to your email"}

@router.post("/verify-otp")
async def verify_otp(request: VerifyOtpRequest, response: Response, req: Request):
    check_rate_limit(req)
    fingerprint = get_device_fingerprint(req)
    print(f"OTP verification from device: {fingerprint}")
    if not db_service.verify_otp(request.email, request.otp):
        raise HTTPException(status_code=400, detail="Invalid or expired OTP")

    user = db_service.get_user_by_email(request.email)

    if not user and request.isSignup:
        # Enforce unique username and phone again (race condition safety)
        if request.username and db_service.get_user_by_username(request.username):
            raise HTTPException(status_code=400, detail="Username already taken")
        if request.phone and db_service.get_user_by_phone(request.phone):
            raise HTTPException(status_code=400, detail="Phone number already registered")
        hashed = bcrypt.hashpw(request.password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
        user_data = {
            "email": request.email,
            "name": request.name,
            "username": request.username,
            "phone": request.phone or "",
            "password": hashed,
            "role": "farmer",
            "points": 0,
            "level": 1,
            "district": "Lucknow" # Default for demo
        }
        db_service.create_user(user_data)
        user = user_data
        # Send welcome email
        try:
            ses_service.send_otp_email(request.email, "Welcome to SathiAI! Your account has been created.")
        except Exception as e:
            print(f"Welcome email failed: {e}")
        # Send welcome SMS if phone is present
        if request.phone:
            try:
                from src.sns_service import sns_service
                sns_service.send_sms(request.phone, "Welcome to SathiAI! Your account has been created.")
            except Exception as e:
                print(f"Welcome SMS failed: {e}")
    elif not user:
        raise HTTPException(status_code=404, detail="User not found. Please signup first.")

    db_service.delete_otp(request.email)

    access_token = jwt.encode({
        "email": user['email'],
        "name": user['name'],
        "exp": datetime.datetime.utcnow() + datetime.timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    }, JWT_SECRET, algorithm="HS256")
    refresh_token = secrets.token_urlsafe(64)
    refresh_tokens[refresh_token] = {
        "email": user['email'],
        "exp": (datetime.datetime.utcnow() + datetime.timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS)).timestamp()
    }
    # Set tokens as secure HTTP-only cookies
    response.set_cookie(key="access_token", value=access_token, httponly=True, secure=True, samesite="lax")
    response.set_cookie(key="refresh_token", value=refresh_token, httponly=True, secure=True, samesite="lax")
    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "user": {
            "name": user['name'],
            "username": user['username'],
            "email": user['email'],
            "phone": user.get('phone', ''),
            "points": user.get('points', 0),
            "level": user.get('level', 1)
        }
    }

@router.post("/login")
async def login(request: LoginRequest, response: Response, req: Request):
    check_rate_limit(req)
    fingerprint = get_device_fingerprint(req)
    print(f"Login attempt from device: {fingerprint}")
    # Example suspicious activity alert: log if login fails
    # Password reset request (send OTP)
    @router.post("/password-reset-request")
    async def password_reset_request(email: str = Body(...), req: Request = None):
        check_rate_limit(req)
        user = db_service.get_user_by_email(email)
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        otp = str(random.randint(100000, 999999))
        db_service.save_otp(email, otp)
        ses_service.send_otp_email(email, otp)
        return {"message": "OTP sent to your email"}

    # Password reset confirm (verify OTP and set new password)
    @router.post("/password-reset-confirm")
    async def password_reset_confirm(email: str = Body(...), otp: str = Body(...), new_password: str = Body(...)):
        if not db_service.verify_otp(email, otp):
            raise HTTPException(status_code=400, detail="Invalid or expired OTP")
        hashed = bcrypt.hashpw(new_password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
        db_service.users_table.update_item(
            Key={"email": email},
            UpdateExpression="SET password = :pw",
            ExpressionAttributeValues={":pw": hashed}
        )
        db_service.delete_otp(email)
        return {"message": "Password reset successful"}

    # User feedback endpoint
    @router.post("/feedback")
    async def user_feedback(email: str = Body(...), feedback: str = Body(...)):
        # Store feedback in DynamoDB or log (for demo, just print)
        print(f"Feedback from {email}: {feedback}")
        return {"message": "Feedback received. Thank you!"}
    user = db_service.get_user_by_email(request.email)
    if not user or not bcrypt.checkpw(request.password.encode('utf-8'), user['password'].encode('utf-8')):
        print(f"Suspicious login failed for {request.email} from device {fingerprint}")
        raise HTTPException(status_code=401, detail="Invalid credentials")
        
    access_token = jwt.encode({
        "email": user['email'],
        "exp": datetime.datetime.utcnow() + datetime.timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    }, JWT_SECRET, algorithm="HS256")
    refresh_token = secrets.token_urlsafe(64)
    refresh_tokens[refresh_token] = {
        "email": user['email'],
        "exp": (datetime.datetime.utcnow() + datetime.timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS)).timestamp()
    }
    response.set_cookie(key="access_token", value=access_token, httponly=True, secure=True, samesite="lax")
    response.set_cookie(key="refresh_token", value=refresh_token, httponly=True, secure=True, samesite="lax")
    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "user": {
            "name": user['name'],
            "username": user['username'],
            "email": user['email'],
            "points": user.get('points', 0),
            "level": user.get('level', 1)
        }
    }

# Refresh token endpoint
@router.post("/refresh-token")
async def refresh_token_endpoint(request: Request, response: Response):
    refresh_token = request.cookies.get("refresh_token")
    if not refresh_token or refresh_token not in refresh_tokens:
        raise HTTPException(status_code=401, detail="Invalid refresh token")
    token_data = refresh_tokens[refresh_token]
    if token_data["exp"] < datetime.datetime.utcnow().timestamp():
        del refresh_tokens[refresh_token]
        raise HTTPException(status_code=401, detail="Refresh token expired")
    user = db_service.get_user_by_email(token_data["email"])
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    access_token = jwt.encode({
        "email": user['email'],
        "exp": datetime.datetime.utcnow() + datetime.timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    }, JWT_SECRET, algorithm="HS256")
    response.set_cookie(key="access_token", value=access_token, httponly=True, secure=True, samesite="lax")
    return {"access_token": access_token}
