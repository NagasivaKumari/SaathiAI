from fastapi import APIRouter, HTTPException
from src.aws_db import db_service
import os
import requests

router = APIRouter()

@router.get("")
async def get_market_data():
    """Fetch all market data from DynamoDB."""
    return db_service.get_market_data()

@router.post("/refresh")
async def refresh_market():
    """Triggers the scraper to fetch live data."""
    from src.services.scraper_service import scraper_service
    success = scraper_service.scrape_market_prices()
    if success:
        return {"message": "Market data refreshed dynamically!"}
    raise HTTPException(status_code=500, detail="Failed to fetch live data")

@router.get("/prices")
async def get_prices(commodity: str = None, state: str = None, lang: str = "en-US"):
    """
    Returns market prices.

    Priority:
    1. If DATA_GOV_IN_API_KEY is set, try to fetch fresh data from data.gov.in
       (resource 9ef84268-d588-465a-a308-a864a43d0070 - Agri market prices).
    2. Fallback to DynamoDB cached data via aws_db.
    """
    api_key = os.getenv("DATA_GOV_IN_API_KEY")

    # 1. Try live data.gov.in API if configured
    if api_key:
        try:
            params = {
                "api-key": api_key,
                "format": "json",
                "limit": 50,
            }
            if commodity:
                params["filters[commodity]"] = commodity
            if state:
                params["filters[state]"] = state

            url = "https://api.data.gov.in/resource/9ef84268-d588-465a-a308-a864a43d0070"
            resp = requests.get(url, params=params, timeout=8)
            if resp.status_code == 200:
                body = resp.json()
                records = body.get("records", [])
                if records:
                    # Normalize field names a bit for the mobile UI
                    normalized = []
                    for r in records:
                        normalized.append(
                            {
                                "id": r.get("id") or r.get("arrival_date") or "",
                                "crop": r.get("commodity") or r.get("crop") or "",
                                "price": r.get("modal_price") or r.get("min_price"),
                                "market": r.get("market") or r.get("market_center"),
                                "state": r.get("state"),
                                "trend": "up",  # data.gov.in doesn't give explicit trend
                                "advice": "",
                            }
                        )
                    return normalized
        except Exception:
            # If live fetch fails, fall back to DynamoDB
            pass

    # 2. Fallback: DynamoDB market table (seeded + scraper)
    data = db_service.get_market_data()
    if commodity:
        commodity_l = commodity.lower()
        data = [
            d
            for d in data
            if commodity_l in d.get("crop", "").lower()
            or commodity_l in d.get("Commodity", "").lower()
        ]
    if state:
        state_l = state.lower()
        data = [
            d
            for d in data
            if state_l in d.get("state", "").lower()
            or state_l in d.get("State", "").lower()
        ]
    return data
