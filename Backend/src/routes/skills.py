from fastapi import APIRouter, HTTPException
from src.s3_service import s3_service
from src.aws_db import db_service
import os
import datetime
import tempfile
from typing import List
from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import A4
from reportlab.lib.units import inch
from reportlab.lib.colors import HexColor

router = APIRouter()

@router.get("")
async def get_skills(q: str = None, category: str = None, lang: str = "en-US", email: str = "sunil@example.com"):
    all_skills = [
        {"id": "1", "name": "Organic Farming", "category": "Agriculture", "description": "Learn sustainable farming", "progress": 70, "duration": "3 weeks", "certificate": True},
        {"id": "2", "name": "Dairy Management", "category": "Agriculture", "description": "Cow care basics", "progress": 100, "duration": "2 weeks", "certificate": True},
        {"id": "3", "name": "Digital Literacy", "category": "Digital", "description": "Using apps for market", "progress": 20, "duration": "1 week", "certificate": False},
        {"id": "4", "name": "Small Business Accounting", "category": "Business", "description": "Manage farm finances", "progress": 0, "duration": "4 weeks", "certificate": True},
        {"id": "5", "name": "Handicrafts & Weaving", "category": "Handicrafts", "description": "Traditional art skills", "progress": 0, "duration": "6 weeks", "certificate": True},
    ]
    
    if q:
        q = q.lower()
        all_skills = [s for s in all_skills if q in s["name"].lower() or q in s["description"].lower()]
    if category:
        category = category.lower()
        all_skills = [s for s in all_skills if category in s.get("category", "").lower()]
        
    return all_skills

@router.get("/search")
async def search_skills(query: str = "", category: str = None, lang: str = "en-US"):
    return await get_skills(q=query, category=category, lang=lang)


@router.post("/start")
async def start_skill(email: str, skill_id: str):
    return {"success": True, "message": "Skill started"}

@router.post("/progress")
async def update_progress(email: str, skill_id: str, progress: float):
    return {"success": True, "message": "Progress updated"}

@router.get("/recommend")
async def recommend_skills(email: str):
    return [{"id": "1", "name": "Organic Farming", "progress": 70, "status": "Continue"}]

@router.post("/complete")
async def complete_module(email: str, skill_name: str):
    # 1. Award Points
    db_service.update_user_gamification(email, 50, 0)
    
    # 2. Generate Professional PDF Certificate
    fd, temp_pdf_path = tempfile.mkstemp(suffix=".pdf")
    try:
        c = canvas.Canvas(temp_pdf_path, pagesize=A4)
        width, height = A4
        
        # Border
        c.setStrokeColor(HexColor('#4CAF50'))
        c.setLineWidth(5)
        c.rect(0.5*inch, 0.5*inch, width-1*inch, height-1*inch)
        
        # Title
        c.setFont("Helvetica-Bold", 30)
        c.drawCentredString(width/2.0, height-2*inch, "SathiAI")
        c.setFont("Helvetica", 20)
        c.drawCentredString(width/2.0, height-2.5*inch, "CERTIFICATE OF COMPLETION")
        
        # Body
        c.setFont("Helvetica", 14)
        c.drawCentredString(width/2.0, height-4.5*inch, "This is to certify that")
        c.setFont("Helvetica-Bold", 22)
        c.drawCentredString(width/2.0, height-5.2*inch, email)
        c.setFont("Helvetica", 14)
        c.drawCentredString(width/2.0, height-5.8*inch, "has successfully completed the module:")
        c.setFont("Helvetica-Bold", 18)
        c.drawCentredString(width/2.0, height-6.5*inch, skill_name)
        
        # Footer
        c.setFont("Helvetica-Oblique", 12)
        c.drawCentredString(width/2.0, 2*inch, f"Date: {datetime.date.today().strftime('%B %d, %Y')}")
        c.drawCentredString(width/2.0, 1.5*inch, "Digitally signed by SathiAI Village Mentor")
        
        c.showPage()
        c.save()
        os.close(fd)
        
        # 3. Upload to S3
        s3_url = s3_service.upload_file(temp_pdf_path, f"certificates/{email}_{skill_name.replace(' ', '_')}.pdf")
        
    finally:
        if os.path.exists(temp_pdf_path):
            os.remove(temp_pdf_path)
    
    return {
        "message": "Module completed!",
        "points_earned": 50,
        "certificate_url": s3_url
    }
