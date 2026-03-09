# FastAPI scaffold for user account features

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, EmailStr
from typing import List, Optional
import hashlib
import random
from src.services.aws_integration import get_user_by_email, create_user, update_user, send_otp_email
import jwt
import os
from datetime import datetime, timedelta

router = APIRouter()

# --- Auth Models ---
class SignupRequest(BaseModel):
    email: EmailStr
    phone: Optional[str]
    password: str

class OTPRequest(BaseModel):
    email: EmailStr
    otp: str

class LoginRequest(BaseModel):
    email: EmailStr
    password: str
    otp: Optional[str]

# --- Profile Models ---
class Profile(BaseModel):
    name: str
    email: EmailStr
    phone: Optional[str]
    photo_url: Optional[str]

# --- Address Models ---
class Address(BaseModel):
    id: Optional[int]
    line1: str
    line2: Optional[str]
    city: str
    state: str
    country: str
    zip: str
    is_default: bool = False

# --- Settings Models ---
class Settings(BaseModel):
    notifications: bool
    language: str
    theme: str
    privacy: dict

# --- Endpoints scaffold ---
@router.post('/auth/signup')
def signup(req: SignupRequest):
    # Check if user exists in DynamoDB
    if get_user_by_email(req.email):
        raise HTTPException(status_code=400, detail="User already exists")
    # Hash password securely
    hashed_password = hashlib.sha256(req.password.encode()).hexdigest()
    # Generate OTP
    otp = str(random.randint(100000, 999999))
    # Store user with OTP (unverified)
    user_data = {
        'email': req.email,
        'phone': req.phone,
        'password': hashed_password,
        'otp': otp,
        'verified': False
    }
    if not create_user(user_data):
        raise HTTPException(status_code=500, detail="Failed to create user")
    # Send OTP via AWS SES
    if not send_otp_email(req.email, otp):
        raise HTTPException(status_code=500, detail="Failed to send OTP email")
    return {"message": "Signup successful, OTP sent"}

@router.post('/auth/login')
def login(req: LoginRequest):
    user = get_user_by_email(req.email)
    if not user:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    hashed_password = hashlib.sha256(req.password.encode()).hexdigest()
    if user['password'] != hashed_password:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    if not user.get('verified', False):
        # If not verified, require OTP
        if not req.otp or req.otp != user.get('otp'):
            raise HTTPException(status_code=401, detail="OTP required or invalid OTP")
        # Mark user as verified
        update_user(req.email, {'verified': True, 'otp': None})
    # Generate JWT token
    jwt_secret = os.getenv('JWT_SECRET', 'dev_secret')
    payload = {
        'email': req.email,
        'exp': datetime.utcnow() + timedelta(days=7)
    }
    token = jwt.encode(payload, jwt_secret, algorithm='HS256')
    return {"message": "Login successful", "token": token}

@router.post('/auth/send-otp')
def send_otp(email: EmailStr):
    user = get_user_by_email(email)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    otp = str(random.randint(100000, 999999))
    update_user(email, {'otp': otp})
    if not send_otp_email(email, otp):
        raise HTTPException(status_code=500, detail="Failed to send OTP email")
    return {"message": f"OTP sent to {email}"}

@router.post('/auth/verify-otp')
def verify_otp(req: OTPRequest):
    user = get_user_by_email(req.email)
    if not user or user.get('otp') != req.otp:
        raise HTTPException(status_code=400, detail="Invalid OTP")
    update_user(req.email, {'verified': True, 'otp': None})
    return {"message": "OTP verified"}

@router.post('/auth/forgot-password')
def forgot_password(email: EmailStr):
    user = get_user_by_email(email)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    otp = str(random.randint(100000, 999999))
    update_user(email, {'otp': otp})
    if not send_otp_email(email, otp):
        raise HTTPException(status_code=500, detail="Failed to send OTP email")
    return {"message": f"OTP sent to {email}"}

@router.post('/auth/reset-password')
def reset_password(email: EmailStr, otp: str, new_password: str):
    user = get_user_by_email(email)
    if not user or user.get('otp') != otp:
        raise HTTPException(status_code=400, detail="Invalid OTP")
    hashed_password = hashlib.sha256(new_password.encode()).hexdigest()
    update_user(email, {'password': hashed_password, 'otp': None})
    return {"message": "Password reset successful"}

@router.get('/profile')
def get_profile(email: EmailStr):
    user = get_user_by_email(email)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return {
        "name": user.get("name", ""),
        "email": user["email"],
        "phone": user.get("phone"),
        "photo_url": user.get("photo_url")
    }

@router.put('/profile')
def update_profile(profile: Profile):
    if not update_user(profile.email, profile.dict()):
        raise HTTPException(status_code=500, detail="Failed to update profile")
    return {"message": "Profile updated", "profile": profile.dict()}

@router.post('/profile/change-password')
def change_password(email: EmailStr, old_password: str, new_password: str):
    user = get_user_by_email(email)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    hashed_old = hashlib.sha256(old_password.encode()).hexdigest()
    if user['password'] != hashed_old:
        raise HTTPException(status_code=400, detail="Old password incorrect")
    hashed_new = hashlib.sha256(new_password.encode()).hexdigest()
    if not update_user(email, {'password': hashed_new}):
        raise HTTPException(status_code=500, detail="Failed to update password")
    return {"message": "Password changed successfully"}

@router.get('/addresses')
def list_addresses(email: EmailStr):
    user = get_user_by_email(email)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user.get('addresses', [])

@router.post('/addresses')
def add_address(email: EmailStr, address: Address):
    user = get_user_by_email(email)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    addresses = user.get('addresses', [])
    address_dict = address.dict()
    address_dict['id'] = len(addresses) + 1
    addresses.append(address_dict)
    if not update_user(email, {'addresses': addresses}):
        raise HTTPException(status_code=500, detail="Failed to add address")
    return {"message": "Address added", "address": address_dict}

@router.put('/addresses/{address_id}')
def update_address(email: EmailStr, address_id: int, address: Address):
    user = get_user_by_email(email)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    addresses = user.get('addresses', [])
    for idx, addr in enumerate(addresses):
        if addr['id'] == address_id:
            addresses[idx] = address.dict()
            addresses[idx]['id'] = address_id
            break
    else:
        raise HTTPException(status_code=404, detail="Address not found")
    if not update_user(email, {'addresses': addresses}):
        raise HTTPException(status_code=500, detail="Failed to update address")
    return {"message": f"Address {address_id} updated", "address": address.dict()}

@router.delete('/addresses/{address_id}')
def delete_address(email: EmailStr, address_id: int):
    user = get_user_by_email(email)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    addresses = user.get('addresses', [])
    addresses = [addr for addr in addresses if addr['id'] != address_id]
    if not update_user(email, {'addresses': addresses}):
        raise HTTPException(status_code=500, detail="Failed to delete address")
    return {"message": f"Address {address_id} deleted"}

@router.put('/addresses/default/{address_id}')
def set_default_address(email: EmailStr, address_id: int):
    user = get_user_by_email(email)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    addresses = user.get('addresses', [])
    for addr in addresses:
        addr['is_default'] = (addr['id'] == address_id)
    if not update_user(email, {'addresses': addresses}):
        raise HTTPException(status_code=500, detail="Failed to set default address")
    return {"message": f"Address {address_id} set as default"}

@router.get('/settings')
def get_settings(email: EmailStr):
    user = get_user_by_email(email)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user.get('settings', {})

@router.put('/settings')
def update_settings(email: EmailStr, settings: Settings):
    if not update_user(email, {'settings': settings.dict()}):
        raise HTTPException(status_code=500, detail="Failed to update settings")
    return {"message": "Settings updated", "settings": settings.dict()}

@router.post('/support/contact')
def contact_support(message: str):
    # Example: Send support message (replace with email/ticket logic)
    return {"message": "Support request sent", "content": message}

@router.get('/support/faq')
def get_faq():
    # Example: Return static FAQ (replace with DB)
    return [
        {"q": "How do I reset my password?", "a": "Go to Forgot Password and follow the instructions."},
        {"q": "How do I contact support?", "a": "Use the Contact Support option in the app."}
    ]

@router.post('/support/report')
def report_problem(description: str):
    # Example: Report a problem (replace with ticket logic)
    return {"message": "Problem reported", "description": description}

@router.get('/legal/terms')
def get_terms():
    # Example: Return static terms (replace with DB/file)
    return {"terms": "Terms of Service go here..."}

@router.get('/legal/privacy')
def get_privacy():
    # Example: Return static privacy policy (replace with DB/file)
    return {"privacy": "Privacy Policy goes here..."}

@router.delete('/account/delete')
def delete_account():
    # Example: Delete account (replace with DB delete)
    return {"message": "Account deleted"}
