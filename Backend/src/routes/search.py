from fastapi import APIRouter, Query
from src.aws_db import db_service

router = APIRouter()

@router.get("")
async def global_search(q: str = Query(...), type: str = None, state: str = None, district: str = None, lang: str = "en-US"):
    """
    Unified search across schemes, market, and skills.
    - q: search query
    - type: filter by 'scheme', 'market', 'skill' (optional)
    - state, district: location filters (optional)
    - lang: language (optional)
    """
    results = []
    if type in (None, "scheme"):
        schemes = db_service.get_all_schemes()
        for s in schemes:
            if q.lower() in s.get("name", "").lower() or q.lower() in s.get("description", "").lower():
                if (not state or state.lower() in s.get("state_availability", "").lower()) and (not district or district.lower() in s.get("district", "").lower()):
                    results.append({"type": "scheme", **s})
    if type in (None, "market"):
        market = db_service.get_market_data()
        for m in market:
            if q.lower() in m.get("crop", "").lower() or q.lower() in m.get("market", "").lower():
                if (not state or state.lower() in m.get("state", "").lower()):
                    results.append({"type": "market", **m})
    if type in (None, "skill"):
        skills = db_service.get_all_skills() if hasattr(db_service, 'get_all_skills') else []
        for sk in skills:
            if q.lower() in sk.get("name", "").lower() or q.lower() in sk.get("description", "").lower():
                results.append({"type": "skill", **sk})
    return results
