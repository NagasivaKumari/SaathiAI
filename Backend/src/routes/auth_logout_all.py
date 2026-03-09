from fastapi import APIRouter, HTTPException, Request, Response
import jwt
import os
from src.routes.auth import refresh_tokens

router = APIRouter()
JWT_SECRET = os.getenv("JWT_SECRET", "sathiai-secret-key")

@router.post("/logout-all")
async def logout_all(request: Request, response: Response):
    # 1. Get token
    access_token = request.cookies.get("access_token")
    if not access_token:
        raise HTTPException(status_code=401, detail="Not authenticated")
    
    # 2. Decode token to get email
    try:
        payload = jwt.decode(access_token, JWT_SECRET, algorithms=["HS256"])
        email = payload.get("email")
    except jwt.ExpiredSignatureError:
        # If access token is expired, try refresh token
        refresh_token = request.cookies.get("refresh_token")
        if refresh_token and refresh_token in refresh_tokens:
            email = refresh_tokens[refresh_token]["email"]
        else:
            raise HTTPException(status_code=401, detail="Tokens expired")
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Invalid token")
        
    if not email:
        raise HTTPException(status_code=401, detail="Invalid token payload")

    # 3. Clear all refresh tokens for this user in memory
    tokens_to_delete = [
        token for token, data in refresh_tokens.items() 
        if data.get("email") == email
    ]
    for token in tokens_to_delete:
        del refresh_tokens[token]
        
    # 4. Clear cookies in the current response
    response.delete_cookie("access_token")
    response.delete_cookie("refresh_token")
    
    return {"message": "Successfully logged out from all devices"}
