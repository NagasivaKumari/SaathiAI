import boto3
import os
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from botocore.exceptions import ClientError

class EmailService:
    def __init__(self):
        # AWS SES Config
        try:
            self.ses = boto3.client(
                'ses',
                region_name=os.getenv("AWS_REGION", "us-east-1"),
                aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"),
                aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY")
            )
        except Exception:
            self.ses = None
            
        self.ses_source = os.getenv("SES_SOURCE_EMAIL")
        
        # Standard SMTP Config (Fallback)
        self.smtp_user = os.getenv("EMAIL_USER")
        self.smtp_pass = os.getenv("EMAIL_PASS")
        self.smtp_server = "smtp.gmail.com"
        self.smtp_port = 587
        
        if not self.smtp_user or not self.smtp_pass:
            print("⚠️ SMTP Fallback not configured (EMAIL_USER/EMAIL_PASS missing)")
        else:
            print(f"✅ SMTP Fallback ready for {self.smtp_user}")

    def send_otp_email(self, destination_email, otp):
        subject = f"Your SathiAI Verification Code: {otp}"
        body_text = f"Welcome to SathiAI!\n\nYour verification code is: {otp}\n\nThis code will expire in 10 minutes."
        
        body_html = f"""
        <html>
        <head></head>
        <body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
            <div style="max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #e0e0e0; border_radius: 10px;">
                <h2 style="color: #2e7d32; text-align: center;">SathiAI Verification</h2>
                <p>Namaste! Welcome to your digital companion, <strong>SathiAI</strong>.</p>
                <p>Please use the following code to verify your account:</p>
                <div style="background-color: #f1f8e9; padding: 20px; text-align: center; border-radius: 5px; margin: 20px 0;">
                    <span style="font-size: 32px; font-weight: bold; letter-spacing: 5px; color: #2e7d32; display: block;">{otp}</span>
                </div>
                <p style="font-size: 12px; color: #757575;">This code will expire in 10 minutes. If you did not request this, please ignore this email.</p>
                <hr style="border: 0; border-top: 1px solid #eee; margin: 20px 0;" />
                <p style="font-size: 10px; color: #bdbdbd; text-align: center;">SathiAI - Empowering Rural India</p>
            </div>
        </body>
        </html>
        """

        # 1. Try Amazon SES (AWS Native Strategy)
        if self.ses and self.ses_source:
            try:
                response = self.ses.send_email(
                    Source=self.ses_source,
                    Destination={'ToAddresses': [destination_email]},
                    Message={
                        'Subject': {'Data': subject, 'Charset': 'UTF-8'},
                        'Body': {
                            'Text': {'Data': body_text, 'Charset': 'UTF-8'},
                            'Html': {'Data': body_html, 'Charset': 'UTF-8'}
                        }
                    }
                )
                print(f"✅ OTP sent via Amazon SES: {response['MessageId']}")
                return response['MessageId']
            except ClientError as e:
                print(f"⚠️ SES failed: {e.response['Error']['Message']}. Trying SMTP fallback...")

        # 2. Try Standard SMTP (Resiliency Strategy using User's Gmail)
        if self.smtp_user and self.smtp_pass:
            try:
                msg = MIMEMultipart('alternative')
                msg['Subject'] = subject
                msg['From'] = self.smtp_user
                msg['To'] = destination_email
                
                msg.attach(MIMEText(body_text, 'plain'))
                msg.attach(MIMEText(body_html, 'html'))
                
                with smtplib.SMTP(self.smtp_server, self.smtp_port) as server:
                    server.starttls()
                    server.login(self.smtp_user, self.smtp_pass)
                    server.send_message(msg)
                
                print(f"✅ OTP sent via SMTP ({self.smtp_user})")
                return "SMTP_SUCCESS"
            except Exception as e:
                print(f"❌ SMTP Backup failed: {e}")
        
        return None

# Global instance
ses_service = EmailService()
