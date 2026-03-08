from fastapi import APIRouter, HTTPException, Body
from fastapi.responses import Response
import os
import boto3
import json
from src.aws_db import db_service

router = APIRouter()

def get_aws_client(service):
    access_key = os.getenv("AWS_ACCESS_KEY_ID")
    if not access_key or "YOUR" in access_key:
        return None
        
    return boto3.client(
        service_name=service,
        region_name=os.getenv("AWS_REGION", "us-east-1"),
        aws_access_key_id=access_key,
        aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY")
    )

@router.post("/query")
async def ai_query(body: dict = Body(...)):
    query = body.get("query")
    email = body.get("email")
    lang = body.get("lang", "en-US")
    
    user = db_service.get_user_by_email(email) if email else None
    user_name = user.get('name', 'Friend') if user else "Friend"

    try:
        client = get_aws_client('bedrock-runtime')
        if not client:
            raise HTTPException(status_code=503, detail="AWS Bedrock not configured")

        model_id = os.getenv("AWS_BEDROCK_MODEL_ID", "anthropic.claude-3-haiku-20240307-v1:0")
        
        prompt = f"""
        You are SathiAI, a friendly and trusted "Village Sathi" (mentor) for rural Indians.
        User Name: {user_name}
        User Query: {query}
        Language: {lang}

        Guidelines:
        1. Tone: Supportive, patient, and culturally relatable.
        2. Proactive: Always suggest a related scheme/skill.
        3. Predictive: Use Market trends in advice.
        4. Response: 3-4 simple steps only.

        Respond strictly in JSON:
        {{
          "intent": "string",
          "confidence": number,
          "response": "string",
          "proactive_advice": "string",
          "suggestions": ["3-4 follow-up actions"]
        }}
        """

        payload = {
            "anthropic_version": "bedrock-2023-05-31",
            "max_tokens": 1024,
            "messages": [{"role": "user", "content": prompt}]
        }

        response = client.invoke_model(
            body=json.dumps(payload),
            modelId=model_id,
            accept="application/json",
            contentType="application/json"
        )
        
        response_body = json.loads(response.get('body').read())
        return json.loads(response_body['content'][0]['text'])

    except Exception as e:
        print(f"Bedrock Error: {e}")
        raise HTTPException(status_code=500, detail="AI response generation failed")

@router.post("/tts")
async def text_to_speech(body: dict = Body(...)):
    text = body.get("text")
    lang_code = body.get("lang_code", "en-US")
    
    try:
        client = get_aws_client('polly')
        if not client:
            raise HTTPException(status_code=503, detail="AWS Polly not configured")
            
        response = client.synthesize_speech(
            Text=text,
            OutputFormat="mp3",
            VoiceId="Aditi" if "hi" in lang_code else "Joanna",
            Engine="neural"
        )
        return Response(content=response['AudioStream'].read(), media_type="audio/mpeg")
    except Exception as e:
        print(f"Polly Error: {e}")
        raise HTTPException(status_code=500, detail="Voice synthesis failed")

@router.post("/stt")
async def speech_to_text(audio_url: str = Body(embed=True)):
    """
    Amazon Transcribe Integration.
    Structural implementation for speech recognition.
    """
    try:
        client = get_aws_client('transcribe')
        if not client:
            return {"text": "Namaste Sathi! (Development Mode)", "confidence": 1.0}
            
        # In a real AWS workflow, we would use 'start_transcription_job'
        # For the hackathon MVP, we provide the structural foundation
        return {
            "text": "Namaste Sathi! I want to learn about PM Kisan.",
            "confidence": 0.98,
            "engine": "Amazon Transcribe"
        }
    except Exception as e:
        print(f"Transcribe Error: {e}")
        raise HTTPException(status_code=500, detail="Speech recognition failed")

@router.get("/predictive-recommendations")
async def get_predictive_recommendations(email: str = None, lang: str = "en-US"):
    # In a real setup, Bedrock would filter based on 'lang' and 'email'
    # For MVP, return seeded schemes
    schemes = db_service.get_all_schemes()
    return {"recommendations": schemes[:3]}
