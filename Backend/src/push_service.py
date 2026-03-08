import requests
import os

# Example for Firebase Cloud Messaging (FCM)
FCM_SERVER_KEY = os.getenv("FCM_SERVER_KEY", "")
FCM_URL = "https://fcm.googleapis.com/fcm/send"

def send_push_notification(token: str, title: str, body: str) -> bool:
    headers = {
        "Authorization": f"key={FCM_SERVER_KEY}",
        "Content-Type": "application/json"
    }
    payload = {
        "to": token,
        "notification": {
            "title": title,
            "body": body
        }
    }
    resp = requests.post(FCM_URL, json=payload, headers=headers)
    return resp.status_code == 200
