# SathiAI Database Schema (MVP)

## Schemes
- id: int (PK)
- name: str
- benefit: str
- eligibility: str
- required_documents: str
- application_steps: str
- official_portal: str
- category: str
- state: str
- district: str
- description: str

## Markets
- id: int (PK)
- crop: str
- price: float
- market: str
- state: str
- district: str
- date: date
- trend: str

## Skills
- id: int (PK)
- name: str
- duration: str
- certificate: bool
- center: str
- category: str
- state: str
- district: str
- description: str

## Users
- id: int (PK)
- name: str
- village: str
- occupation: str
- language: str
- voice_preference: bool
- state: str
- district: str
- location: str

## Notifications
- id: int (PK)
- user_id: int (FK)
- message: str
- is_read: bool
- created_at: datetime

---
# Notes
- All tables can be implemented in SQLAlchemy (FastAPI backend)
- Add indexes on state, district for fast filtering
- Use relationships for user-notifications
- Extend as needed for MVP
