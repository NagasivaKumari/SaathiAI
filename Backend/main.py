from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv

# Load environment variables BEFORE importing routes
load_dotenv()

from src.routes import auth, ai, market, schemes, user, skills, sync, gamification, search

app = FastAPI(title="SathiAI AWS-Powered API", version="1.0.0")

# CORS Configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Middleware to collapse double slashes to single slashes
@app.middleware("http")
async def collapse_slashes(request, call_next):
    path = request.scope["path"]
    if "//" in path:
        request.scope["path"] = path.replace("//", "/")
    return await call_next(request)

@app.get("/")
async def root():
    return {"message": "SathiAI AWS-Powered API is running"}

@app.get("/api/health")
async def health_check():
    return {
        "status": "ok", 
        "engine": "FastAPI", 
        "database": "Amazon DynamoDB",
        "voice": "Amazon Polly",
        "ai": "Amazon Bedrock"
    }

# Include routers
app.include_router(auth.router, prefix="/api/auth", tags=["auth"])
app.include_router(ai.router, prefix="/api/ai", tags=["ai"])
app.include_router(market.router, prefix="/api/market", tags=["market"])
app.include_router(schemes.router, prefix="/api/schemes", tags=["schemes"])
app.include_router(user.router, prefix="/api/user", tags=["user"])
app.include_router(skills.router, prefix="/api/skills", tags=["skills"])
app.include_router(sync.router, prefix="/api/sync", tags=["sync"])
app.include_router(gamification.router, prefix="/api/gamification", tags=["gamification"])
app.include_router(search.router, prefix="/api/search", tags=["search"])

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
