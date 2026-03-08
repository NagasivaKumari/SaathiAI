import time
from fastapi import Request, HTTPException
from collections import defaultdict

# Simple in-memory rate limiter (per IP + endpoint)
RATE_LIMIT = 5  # requests
RATE_PERIOD = 60  # seconds

# { (ip, endpoint): [timestamps] }
rate_limit_store = defaultdict(list)

def check_rate_limit(request: Request):
    ip = request.client.host
    endpoint = request.url.path
    now = time.time()
    key = (ip, endpoint)
    timestamps = rate_limit_store[key]
    # Remove old timestamps
    rate_limit_store[key] = [t for t in timestamps if now - t < RATE_PERIOD]
    if len(rate_limit_store[key]) >= RATE_LIMIT:
        raise HTTPException(status_code=429, detail="Too many requests. Please try again later.")
    rate_limit_store[key].append(now)
