# SathiAI Backend

SathiAI is a production-ready, AI-powered platform for rural empowerment, built on AWS and designed for seamless integration with Flutter and web/mobile frontends.

---

## Features

- **User Management:** OTP-based signup/login, password reset, profile update, account deletion/export, profile completeness check
- **Authentication:** JWT access/refresh tokens, secure cookies, rate limiting, device fingerprinting, suspicious activity logging
- **Notifications:** Push notifications (Firebase/FCM), in-app notification center, SMS/email alerts
- **AI/ML:** Amazon Bedrock-powered chat, text-to-speech (Polly), speech-to-text (Transcribe)
- **Analytics:** User activity logging, crash/error reporting
- **Compliance:** GDPR-ready account export/deletion, privacy/terms/help endpoints
- **Cloud Native:** AWS DynamoDB, S3, SES, SNS, Bedrock, Polly, Transcribe
- **Security:** Bcrypt password hashing, CORS, HTTPS, environment-based secrets

---

## Quickstart

### Prerequisites
- Python 3.10+
- AWS account (for DynamoDB, S3, SES, SNS, Bedrock, Polly, Transcribe)
- Node.js (for frontend)

### Setup
1. Clone the repo and `cd Backend`
2. Copy `.env.example` to `.env` and fill in your keys:
   - **AWS:** `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION` (used for Bedrock, Polly, Transcribe, DynamoDB, S3)
   - **Bedrock:** `AWS_BEDROCK_MODEL_ID` (e.g. `anthropic.claude-3-haiku-20240307-v1:0`)
   - **Live data:** `DATA_GOV_IN_API_KEY` for real agri market prices from data.gov.in; optional `SCHEMES_API_URL` / `SCHEMES_SCRAPE_URL` for scheme scraping
3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
4. Run the backend:
   ```bash
   uvicorn src.main:app --reload
   ```

---

## API Overview

### Auth/User
- `POST /api/auth/send-otp` — Send OTP for signup/login
- `POST /api/auth/verify-otp` — Verify OTP and create/login user
- `POST /api/auth/login` — Login with email/password
- `POST /api/auth/refresh-token` — Get new access token
- `POST /api/auth/password-reset-request` — Request password reset OTP
- `POST /api/auth/password-reset-confirm` — Reset password
- `GET /api/user/profile` — Get user profile
- `PUT /api/user/update` — Update profile
- `POST /api/user/profile-picture` — Upload profile picture (S3)
- `GET /api/user/profile-completeness` — Profile completeness %
- `DELETE /api/user/delete-account` — Delete account
- `GET /api/user/export-account` — Export user data

### Notifications
- `POST /api/user/send-push` — Send push notification (FCM)
- `POST /api/user/notify-in-app` — Add in-app notification
- `GET /api/user/in-app-notifications` — List in-app notifications
- `POST /api/user/mark-notification-read` — Mark notification as read
- `POST /api/user/send-sms-alert` — Send SMS alert

### Analytics/Crash
- `POST /api/user/log-analytics` — Log analytics event
- `POST /api/user/log-crash` — Log crash/error

### AI/Voice
- `POST /api/ai/query` — AI chat (Bedrock)
- `POST /api/ai/tts` — Text-to-speech (Polly)
- `POST /api/ai/stt` — Speech-to-text (Transcribe)

---

## Integration Guide

- Call these endpoints from your Flutter/web app for all user flows.
- For push notifications, register device tokens in the app and send to `/send-push`.
- For analytics/crash, POST events/errors to `/log-analytics` and `/log-crash`.
- Use cookies for session management (access/refresh tokens).
- For file uploads (profile picture), use multipart/form-data.

---

## Deployment

- Deploy on AWS Lambda/API Gateway (see `serverless.yml`), or any cloud supporting FastAPI.
- Use AWS DynamoDB, S3, SES, SNS, Bedrock, Polly, Transcribe for full feature set.
- Store secrets in `.env` (see `.env.example`).

---

## Security & Compliance
- All secrets in environment variables
- JWT, bcrypt, CORS, HTTPS
- GDPR-ready account export/deletion

---

## License
MIT
