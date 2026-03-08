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
    
    if q:
        q = q.lower()
        schemes = [s for s in schemes if q in s.get("name", "").lower() or q in s.get("description", "").lower() or q in s.get("category", "").lower()]
    if category:
        category = category.lower()
        schemes = [s for s in schemes if category in s.get("category", "").lower()]
    if state:
        state = state.lower()
        schemes = [s for s in schemes if state in s.get("state_availability", "").lower() or "all india" in s.get("state_availability", "").lower()]
        
    return schemes
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
