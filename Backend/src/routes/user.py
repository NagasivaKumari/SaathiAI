
from fastapi import APIRouter, HTTPException, Query, Body, UploadFile, File
import tempfile
from src.s3_service import s3_service
from src.aws_db import db_service
import os
import jwt
from typing import Optional, List

router = APIRouter()
JWT_SECRET = os.getenv("JWT_SECRET", "sathiai-secret-key")


# Push notification endpoint (Firebase/FCM)
@router.post("/send-push")
async def send_push(email: str = Body(...), token: str = Body(...), title: str = Body(...), body: str = Body(...)):
    from src.push_service import send_push_notification
    success = send_push_notification(token, title, body)
    if not success:
        raise HTTPException(status_code=500, detail="Push notification failed")
    return {"success": True}

# In-app notification center endpoints (demo: store in memory)
in_app_notifications = {}

@router.post("/notify-in-app")
async def notify_in_app(email: str = Body(...), message: str = Body(...)):
    in_app_notifications.setdefault(email, []).append({"message": message, "read": False})
    return {"success": True}

@router.get("/in-app-notifications")
async def get_in_app_notifications(email: str = Query(...)):
    return {"notifications": in_app_notifications.get(email, [])}

@router.post("/mark-notification-read")
async def mark_notification_read(email: str = Body(...), idx: int = Body(...)):
    if email in in_app_notifications and 0 <= idx < len(in_app_notifications[email]):
        in_app_notifications[email][idx]["read"] = True
        return {"success": True}
    return {"success": False}

# Analytics and crash/error reporting endpoints
@router.post("/log-analytics")
async def log_analytics(email: str = Body(...), event: str = Body(...), details: dict = Body(None)):
    print(f"Analytics: {email} - {event} - {details}")
    return {"success": True}

@router.post("/log-crash")
async def log_crash(email: str = Body(...), error: str = Body(...), stack: str = Body(None)):
    print(f"Crash: {email} - {error} - {stack}")
    return {"success": True}
# Account deletion endpoint
@router.delete("/delete-account")
async def delete_account(email: str = Query(...)):
    user = db_service.get_user_by_email(email)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    db_service.users_table.delete_item(Key={"email": email})
    return {"success": True, "message": "Account deleted"}

# User data export endpoint
@router.get("/export-account")
async def export_account(email: str = Query(...)):
    user = db_service.get_user_by_email(email)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    # Remove sensitive fields (like password)
    user_export = {k: v for k, v in user.items() if k != "password"}
    return {"user_data": user_export}
# Profile completeness check endpoint
@router.get("/profile-completeness")
async def profile_completeness(email: str = Query(...)):
    user = db_service.get_user_by_email(email)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    required_fields = ["name", "email", "phone", "address", "language"]
    filled = sum(1 for f in required_fields if user.get(f))
    completeness = int((filled / len(required_fields)) * 100)
    return {"completeness": completeness}
# Privacy, terms, help/FAQ endpoints
@router.get("/privacy")
async def privacy_policy():
    return {"privacy": "Your data is secure. We do not share your information with third parties except as required for service delivery."}

@router.get("/terms")
async def terms_of_service():
    return {"terms": "By using SathiAI, you agree to our terms of service. See website for full details."}

@router.get("/help")
async def help_faq():
    return {"faq": [
        {"q": "How do I reset my password?", "a": "Use the password reset option on the login screen."},
        {"q": "How do I update my profile?", "a": "Go to profile settings and edit your information."}
    ]}

# Send SMS alert endpoint
@router.post("/send-sms-alert")
async def send_sms_alert(phone: str = Body(...), message: str = Body(...)):
    from src.sns_service import sns_service
    success = sns_service.send_sms(phone, message)
    if not success:
        raise HTTPException(status_code=500, detail="Failed to send SMS")
    return {"success": True, "message": "SMS sent"}
from fastapi import APIRouter, HTTPException, Query, Body, UploadFile, File
import tempfile
from src.s3_service import s3_service
from src.aws_db import db_service
import os
import jwt
from typing import Optional, List

router = APIRouter()
JWT_SECRET = os.getenv("JWT_SECRET", "sathiai-secret-key")

@router.get("/dashboard")
async def get_dashboard(email: str = Query(...)):
    user = db_service.get_user_by_email(email)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    return {
        "user": {
            "name": user['name'],
            "email": user['email'],
            "points": user.get('points', 0),
            "level": user.get('level', 1),
            "nextPayout": "15th Oct",
            "nextScheme": "PM Kisan"
        }
    }

@router.get("/profile")
async def get_profile(email: str = Query(...)):
    user = db_service.get_user_by_email(email)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user


# Update user profile fields (name, phone, address, language, preferences)
@router.put("/update")
async def update_profile(
    email: str,
    name: str = None,
    phone: str = None,
    address: str = None,
    language: str = None,
    preferences: dict = Body(None)
):
    user = db_service.get_user_by_email(email)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    update_expr = []
    expr_attr_values = {}
    expr_attr_names = {}
    if name:
        update_expr.append("#n = :name")
        expr_attr_values[":name"] = name
        expr_attr_names["#n"] = "name"
    if phone:
        update_expr.append("phone = :phone")
        expr_attr_values[":phone"] = phone
    if address:
        update_expr.append("address = :address")
        expr_attr_values[":address"] = address
    if language:
        update_expr.append("language = :language")
        expr_attr_values[":language"] = language
    if preferences:
        update_expr.append("preferences = :preferences")
        expr_attr_values[":preferences"] = preferences
    if not update_expr:
        return {"success": False, "message": "No fields to update"}
    try:
        db_service.users_table.update_item(
            Key={"email": email},
            UpdateExpression="SET " + ", ".join(update_expr),
            ExpressionAttributeValues=expr_attr_values,
            ExpressionAttributeNames=expr_attr_names if expr_attr_names else None
        )
        return {"success": True}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Update failed: {e}")


# Profile picture upload endpoint (S3)
@router.post("/profile-picture")
async def upload_profile_picture(email: str = Query(...), file: UploadFile = File(...)):
    user = db_service.get_user_by_email(email)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    filename = f"profile_{email}_{int(time.time())}_{file.filename}"
    # Save to temp file for S3 upload
    with tempfile.NamedTemporaryFile(delete=False) as tmp:
        content = await file.read()
        tmp.write(content)
        tmp.flush()
        s3_url = s3_service.upload_file(tmp.name, filename)
    if not s3_url:
        raise HTTPException(status_code=500, detail="Failed to upload to S3")
    # Update user record with S3 URL
    db_service.users_table.update_item(
        Key={"email": email},
        UpdateExpression="SET profile_picture = :pic",
        ExpressionAttributeValues={":pic": s3_url}
    )
    return {"success": True, "url": s3_url}

@router.get("/activity")
async def get_activity(email: str = Query(...)):
    return [
        {"type": "scheme_applied", "scheme": "PM Kisan", "date": "2026-03-01"},
        {"type": "skill_completed", "skill": "Dairy Management", "date": "2026-02-28"}
    ]

@router.post("/reward")
async def award_points(
    points: int = Query(...), 
    reason: str = Query(...), 
    email: Optional[str] = Query(None),
    userId: Optional[str] = Query(None)
):
    target_email = email or userId
    if not target_email:
        raise HTTPException(status_code=400, detail="email or userId required")
        
    user = db_service.get_user_by_email(target_email)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
        
    new_points = user.get('points', 0) + points
    new_level = (new_points // 100) + 1
    
    db_service.update_user_gamification(target_email, points, new_level)
    
    return {
        "message": f"Success! Earned {points} for {reason}",
        "new_points": new_points,
        "new_level": new_level
    }

@router.get("/leaderboard")
async def get_leaderboard():
    # In production, scan is expensive - use GSI
    return [
        {"name": "Siva", "points": 1200, "level": 12},
        {"name": "Mansi", "points": 950, "level": 10},
        {"name": "Rahul", "points": 800, "level": 8}
    ]

@router.get("/alerts")
async def get_alerts(email: str = Query(...)):
    return [
        {"id": 1, "message": "Scheme payout credited!", "read": False},
        {"id": 2, "message": "Apply for PM Kisan scheme today!", "read": True}
    ]
