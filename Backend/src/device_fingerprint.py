import hashlib
from fastapi import Request

def get_device_fingerprint(request: Request) -> str:
    # Use user-agent, IP, and accept headers for a simple fingerprint
    user_agent = request.headers.get('user-agent', '')
    accept = request.headers.get('accept', '')
    ip = request.client.host
    raw = f"{user_agent}|{accept}|{ip}"
    return hashlib.sha256(raw.encode()).hexdigest()
