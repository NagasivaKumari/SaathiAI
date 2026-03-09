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
    Returns market prices with multilingual support (future-proofed for language-specific fields).
    """
    api_key = os.getenv("DATA_GOV_IN_API_KEY")

    def localize(item):
        def pick(field):
            val = item.get(field)
            if isinstance(val, dict):
                return val.get(lang) or val.get(lang.split("-")[0]) or val.get("en") or next(iter(val.values()), "")
            return val
        return {
            **item,
            "crop": pick("crop"),
            "market": pick("market") if "market" in item else item.get("market", ""),
            "trend": pick("trend") if "trend" in item else item.get("trend", ""),
        }

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
                    normalized = []
                    for r in records:
                        item = {
                            "id": r.get("id") or r.get("arrival_date") or "",
                            "crop": r.get("commodity") or r.get("crop") or "",
                            "price": r.get("modal_price") or r.get("min_price"),
                            "market": r.get("market") or r.get("market_center") or "",
                            "trend": r.get("trend", "stable"),
                        }
                        normalized.append(localize(item))
                    return normalized
        except Exception as e:
            pass

    # 2. Fallback to DynamoDB cached data via aws_db
    market_data = db_service.get_market_data()
    filtered = []
    for m in market_data:
        m_local = localize(m)
        if commodity and commodity.lower() not in m_local.get("crop", "").lower():
            continue
        if state and state.lower() not in m.get("state", "").lower():
            continue
        filtered.append(m_local)
    
    if filtered:
        return filtered

    # 2. DynamoDB (seeded + scraper) or in-memory demo when no API key and no DB
    data = db_service.get_market_data()
    if not data:
        # No API key and no DB: return demo data so app still shows content
        data = [
            {"id": "m1", "crop": "Wheat", "price": "2345", "trend": "up", "change": "120", "market": "Indore Mandi"},
            {"id": "m2", "crop": "Tomato", "price": "2450", "trend": "up", "change": "120", "market": "Azadpur Mandi"},
            {"id": "m3", "crop": "Potato", "price": "1580", "trend": "up", "change": "45", "market": "Agra Mandi"},
            {"id": "m4", "crop": "Rice (Basmati)", "price": "3800", "trend": "up", "change": "45", "market": "Punjab Mandi"},
        ]
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

@router.get("/bulk")
async def get_market_bulk(lang: str = "en-US"):
    """Return all market data in bulk for offline caching (language-aware)."""
    market_data = db_service.get_market_data()
    def localize(item):
        def pick(field):
            val = item.get(field)
            if isinstance(val, dict):
                return val.get(lang) or val.get(lang.split("-")[0]) or val.get("en") or next(iter(val.values()), "")
            return val
        return {
            **item,
            "crop": pick("crop"),
            "market": pick("market") if "market" in item else item.get("market", ""),
            "trend": pick("trend") if "trend" in item else item.get("trend", ""),
        }
    return [localize(m) for m in market_data]
