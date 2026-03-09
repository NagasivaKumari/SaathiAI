import os
import sys
import time
import subprocess
from datetime import datetime

# This script will schedule fetch_agmarknet_prices.py to run daily at 6:00 AM using Windows Task Scheduler
# Usage: python schedule_fetch_agmarknet.py

SCRIPT_PATH = os.path.abspath(os.path.join(os.path.dirname(__file__), 'fetch_agmarknet_prices.py'))
PYTHON_PATH = sys.executable  # Path to current Python interpreter
TASK_NAME = "SathiAI_UpdateMandiPrices"

# Create the command to run
cmd = f'"{PYTHON_PATH}" "{SCRIPT_PATH}"'

# Create the schtasks command
schtasks_cmd = [
    'schtasks',
    '/Create',
    '/SC', 'DAILY',
    '/TN', TASK_NAME,
    '/TR', cmd,
    '/ST', '06:00',
    '/F'  # Force update if task exists
]

if __name__ == "__main__":
    print(f"Scheduling daily mandi price update at 6:00 AM using Task Scheduler...")
    try:
        result = subprocess.run(schtasks_cmd, capture_output=True, text=True)
        if result.returncode == 0:
            print("Task scheduled successfully!")
        else:
            print("Failed to schedule task:")
            print(result.stdout)
            print(result.stderr)
    except Exception as e:
        print(f"Error: {e}")
