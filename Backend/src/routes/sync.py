from fastapi import APIRouter, HTTPException, Body
from src.aws_db import db_service
import datetime

router = APIRouter()

@router.get("/pull")
async def pull_updates(email: str, last_sync: float):
    """Fetch all updates since last_sync for offline caching."""
    user = db_service.get_user_by_email(email)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
        
    return {
        "server_time": datetime.datetime.now().timestamp(),
        "user_data": user,
        "schemes": db_service.get_all_schemes()
    }

@router.post("/push")
async def push_updates(email: str, data: dict = Body(...)):
    """Reconcile offline activity (points, level) with DynamoDB."""
    points = data.get("pending_points", 0)
    level = data.get("current_level", 1)
    
    db_service.update_user_gamification(email, points, level)
    return {"status": "synced", "points_added": points}
