import json
import os

SCHEMES_PATH = "d:/SaathiAI/Schemes/govt_schemes.json"

def read_schemes_json():
    if not os.path.exists(SCHEMES_PATH):
        return []
    try:
        with open(SCHEMES_PATH, "r", encoding="utf-8") as f:
            data = json.load(f)
            return data.get("schemes", [])
    except Exception as e:
        print(f"Error reading schemes: {e}")
        return []
