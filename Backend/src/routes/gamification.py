from fastapi import APIRouter, HTTPException
from src.aws_db import db_service

router = APIRouter()


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
    "streak": streak,
    "milestone": milestone,
  }

