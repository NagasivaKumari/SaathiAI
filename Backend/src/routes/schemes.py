from fastapi import APIRouter, HTTPException
from src.aws_db import db_service

router = APIRouter()

@router.get("")
async def get_schemes(q: str = None, category: str = None, state: str = None, lang: str = "en-US"):
    schemes = db_service.get_all_schemes()
    if not schemes:
        return []
    
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
