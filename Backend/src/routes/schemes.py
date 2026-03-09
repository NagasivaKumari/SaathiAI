
from fastapi import APIRouter, HTTPException
from src.aws_db import db_service

router = APIRouter()

# In-memory fallback when DynamoDB is not configured (no API keys required)
_SCHEMES_FALLBACK = [
    {"id": "s1", "name": "PM-Kisan Samman Nidhi", "description": "₹6,000 yearly direct income support for small and marginal farmers.", "status": "Active", "category": "Agriculture"},
    {"id": "s2", "name": "Ayushman Bharat (PM-JAY)", "description": "Free health cover up to ₹5 Lakhs per family per year.", "status": "Active", "category": "Health"},
    {"id": "s3", "name": "PM Awas Yojana (Gramin)", "description": "Housing for all in rural areas.", "status": "Active", "category": "Housing"},
]

@router.get("")
async def get_schemes(q: str = None, category: str = None, state: str = None, lang: str = "en-US"):
    schemes = db_service.get_all_schemes()
    if not schemes:
        schemes = list(_SCHEMES_FALLBACK)

    # Multilingual support: try to return fields in requested language, fallback to English
    def localize(item):
        def pick(field):
            val = item.get(field)
            if isinstance(val, dict):
                # e.g. {"en": "...", "hi": "...", "te": "..."}
                return val.get(lang) or val.get(lang.split("-")[0]) or val.get("en") or next(iter(val.values()), "")
            return val
        return {
            **item,
            "name": pick("name"),
            "description": pick("description"),
            "category": pick("category"),
            "status": pick("status")
        }

    filtered = []
    for s in schemes:
        s_local = localize(s)
        if q and q.lower() not in (s_local.get("name", "") + s_local.get("description", "") + s_local.get("category", "")).lower():
            continue
        if category and category.lower() not in s_local.get("category", "").lower():
            continue
        if state and state.lower() not in s.get("state_availability", "").lower() and "all india" not in s.get("state_availability", "").lower():
            continue
        filtered.append(s_local)
    return filtered
@router.get("/{scheme_id}")
async def get_scheme(scheme_id: str):
    """Return a single scheme by its ID with full detail fields."""
    scheme = db_service.get_scheme_by_id(scheme_id)
    if not scheme:
        raise HTTPException(status_code=404, detail="Scheme not found")
    return scheme



@router.post("/refresh")
async def refresh_schemes():
    """Triggers the scraper to fetch fresh government schemes."""
    from src.services.scraper_service import scraper_service
    success = scraper_service.scrape_schemes()
    if success:
        return {"message": "Government schemes synchronized live!"}
    raise HTTPException(status_code=500, detail="Failed to sync schemes")

@router.get("/bulk")
async def get_schemes_bulk(lang: str = "en-US"):
    """Return all schemes in bulk for offline caching (language-aware)."""
    schemes = db_service.get_all_schemes()
    if not schemes:
        schemes = list(_SCHEMES_FALLBACK)
    def localize(item):
        def pick(field):
            val = item.get(field)
            if isinstance(val, dict):
                return val.get(lang) or val.get(lang.split("-")[0]) or val.get("en") or next(iter(val.values()), "")
            return val
        return {
            **item,
            "name": pick("name"),
            "description": pick("description"),
            "category": pick("category"),
            "status": pick("status")
        }
    return [localize(s) for s in schemes]
