# Security & Cloud Deployment

## Security Best Practices
- All sensitive API keys (Gemini, Agmarknet, etc.) are stored in environment variables and never hardcoded.
- JWT authentication is used for all user endpoints. Tokens are required for profile and protected routes.
- Passwords are hashed using bcrypt before storing in the database.
- CORS is enabled for API routes.
- Always use HTTPS in production deployments.
- Regularly update dependencies to patch vulnerabilities.

## Cloud Deployment
- Recommended platforms: AWS Lambda/API Gateway, Google Cloud Run, or Azure Functions for backend APIs.
- Use managed databases (AWS RDS, Google Cloud SQL) for scalability.
- Store secrets in cloud secret managers (AWS Secrets Manager, GCP Secret Manager).
- Use CI/CD pipelines for automated deployment and testing.
- Enable auto-scaling and health checks for high availability.
- Use S3 or GCS for static asset hosting and backups.

## Scalability
- Stateless backend APIs for easy scaling.
- Modular codebase for adding new features and endpoints.
- Use caching (Redis, CDN) for frequently accessed data.
- Monitor usage and errors with cloud logging and alerting.
<div align="center">
<img width="1200" height="475" alt="GHBanner" src="https://github.com/user-attachments/assets/0aa67016-6eaf-458a-adb2-6e31a0763ed6" />
</div>

# Run and deploy your AI Studio app

This contains everything you need to run your app locally.

View your app in AI Studio: https://ai.studio/apps/f0323112-2235-42d9-b6e4-e374dc59482c

## Run Locally

**Prerequisites:**  Node.js


1. Install dependencies:
   `npm install`
2. Set the `GEMINI_API_KEY` in [.env.local](.env.local) to your Gemini API key
3. Run the app:
   `npm run dev`
