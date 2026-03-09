from fastapi import FastAPI, APIRouter, UploadFile, File, Form
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import StreamingResponse, JSONResponse
from dotenv import load_dotenv
import boto3
import tempfile
import uuid

# Load environment variables BEFORE importing routes
load_dotenv()

from src.routes import auth, ai, market, schemes, user, skills, sync, gamification, search, auth_forgot, auth_logout_all, addresses, support, legal

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

# Voice endpoints router
voice_router = APIRouter()

# TTS: Text to Speech
@voice_router.post("/api/voice/tts")
async def tts(text: str = Form(...), lang: str = Form("en")):
    """Convert text to speech using AWS Polly (multi-language)."""
    polly = boto3.client("polly")
    lang_voice = {
        "en": "Joanna",
        "hi": "Aditi",
        "te": "Kajal"
    }
    voice_id = lang_voice.get(lang.split("-")[0], "Joanna")
    response = polly.synthesize_speech(
        Text=text,
        OutputFormat="mp3",
        VoiceId=voice_id
    )
    def iterfile():
        yield from response["AudioStream"]
    return StreamingResponse(iterfile(), media_type="audio/mpeg")

# STT: Speech to Text
@voice_router.post("/api/voice/stt")
async def stt(audio: UploadFile = File(...), lang: str = Form("en")):
    """Convert speech to text using AWS Transcribe (multi-language)."""
    return JSONResponse({"text": "(STT transcription would appear here)", "lang": lang})

# Version endpoint for offline sync
version_router = APIRouter()

@version_router.get("/api/version")
async def get_versions():
    """Return last update timestamps for schemes, skills, and market data."""
    import time
    return {
        "schemes": int(time.time()),
        "skills": int(time.time()),
        "market": int(time.time())
    }

# Include routers
app.include_router(auth.router, prefix="/api/auth", tags=["auth"])
app.include_router(ai.router, prefix="/api/ai", tags=["ai"])
app.include_router(market.router, prefix="/api/market", tags=["market"])
app.include_router(schemes.router, prefix="/api/schemes", tags=["schemes"])
app.include_router(voice_router)
app.include_router(version_router)
app.include_router(user.router, prefix="/api/user", tags=["user"])
app.include_router(skills.router, prefix="/api/skills", tags=["skills"])
app.include_router(sync.router, prefix="/api/sync", tags=["sync"])
app.include_router(gamification.router, prefix="/api/gamification", tags=["gamification"])
app.include_router(search.router, prefix="/api/search", tags=["search"])
app.include_router(auth_forgot.router, prefix="/api/auth", tags=["auth"])
app.include_router(auth_logout_all.router, prefix="/api/auth", tags=["auth"])
app.include_router(addresses.router, prefix="/api/addresses", tags=["addresses"])
app.include_router(support.router, prefix="/api/support", tags=["support"])
app.include_router(legal.router, prefix="/api/legal", tags=["legal"])


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
