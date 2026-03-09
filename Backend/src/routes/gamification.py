from fastapi import APIRouter, HTTPException, Body, Request
from pydantic import BaseModel
from src.aws_db import db_service
from src.rate_limit import check_rate_limit

router = APIRouter()

class AwardRequest(BaseModel):
    email: str
    action: str

# Gamification logic configurations
LEVEL_THRESHOLDS = {
    1: 0,
    2: 100,
    3: 300,
    4: 600,
    5: 1000,
    6: 1500,
    7: 2100,
    8: 2800,
    9: 3600,
    10: 4500,
}

ACTION_POINTS = {
    'scheme_view': 10,
    'skill_complete': 50,
    'voice_query': 5,
    'daily_login': 20,
    'market_check': 10,
    'profile_complete': 100
}

def calculate_level_and_badge(points: int):
    level = 1
    for lvl, threshold in sorted(LEVEL_THRESHOLDS.items(), reverse=True):
        if points >= threshold:
            level = lvl
            break
            
    if level >= 10:
        badge = "Village Sathi Mentor"
    elif level >= 7:
        badge = "Platinum Farmer"
    elif level >= 4:
        badge = "Gold Explorer"
    elif level >= 2:
        badge = "Silver Learner"
    else:
        badge = "Bronze Beginner"
        
    return level, badge


@router.get("/leaderboard")
async def get_leaderboard():
  """
  Public leaderboard for SathiAI gamification.

  For now this returns a small static list. In a full
  implementation this would scan/query a DynamoDB table
  with a GSI on points/level.
  """
  # Try to read from DynamoDB if available; otherwise fall back to static data.
  try:
    # This assumes users_table exists and has points/level attributes.
    # A real implementation would use a GSI and pagination.
    table = db_service.users_table if getattr(db_service, "users_table", None) else None
    if table is not None:
      response = table.scan(Limit=50)
      items = response.get("Items", [])
      # Sort by points desc, then level desc
      items.sort(key=lambda u: (u.get("points", 0), u.get("level", 1)), reverse=True)
      return [
        {
          "name": u.get("name", "Farmer"),
          "points": u.get("points", 0),
          "level": u.get("level", 1),
        }
        for u in items[:20]
      ]
  except Exception:
    # Fall back to static sample leaderboard
    pass

  return [
    {"name": "Siva", "points": 1200, "level": 12},
    {"name": "Mansi", "points": 950, "level": 10},
    {"name": "Rahul", "points": 800, "level": 8},
  ]


@router.get("/user/{user_id}")
async def get_user_gamification(user_id: str):
  """
  Return gamification summary for a single user.

  The client currently passes an ID string; in this MVP we
  treat it as the user's email, since DynamoDB uses email
  as the primary key.
  """
  user = db_service.get_user_by_email(user_id)
  if not user:
    raise HTTPException(status_code=404, detail="User not found")

  points = user.get("points", 0)
  level = user.get("level", 1)

  # Simple derived fields for streak/milestone to drive UI
  streak = user.get("streak", 0) or 0
  milestone = points >= 1000

  return {
    "email": user.get("email", user_id),
    "name": user.get("name", "Farmer"),
    "points": points,
    "level": level,
    "badge": badge,
    "streak": streak,
    "milestone": milestone,
  }

@router.post("/award")
async def award_points(request: AwardRequest, req: Request):
    check_rate_limit(req)
    user = db_service.get_user_by_email(request.email)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
        
    points_to_award = ACTION_POINTS.get(request.action, 0)
    if points_to_award <= 0:
        return {"message": "Invalid action, no points awarded", "awarded": 0}
        
    current_points = int(user.get('points', 0))
    new_points = current_points + points_to_award
    new_level, new_badge = calculate_level_and_badge(new_points)
    
    # Update user in DB
    try:
        db_service.users_table.update_item(
           Key={"email": request.email},
           UpdateExpression="SET points = :p, #lvl = :l, badge = :b",
           ExpressionAttributeNames={"#lvl": "level"},
           ExpressionAttributeValues={":p": new_points, ":l": new_level, ":b": new_badge}
        )
    except Exception as e:
        print(f"Error updating gamification points: {e}")
        raise HTTPException(status_code=500, detail="Database failure")
        
    return {
        "message": f"Awarded {points_to_award} points!",
        "awarded": points_to_award,
        "total_points": new_points,
        "level": new_level,
        "badge": new_badge
    }

