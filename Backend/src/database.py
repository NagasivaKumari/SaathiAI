import sqlite3
import os
from datetime import datetime

DB_PATH = 'sathiai.db'

def get_db():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn

def init_db():
    conn = get_db()
    cursor = conn.cursor()
    
    # Users table
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            username TEXT UNIQUE NOT NULL,
            email TEXT UNIQUE NOT NULL,
            phone TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL,
            role TEXT DEFAULT 'farmer',
            district TEXT,
            points INTEGER DEFAULT 0,
            level INTEGER DEFAULT 1,
            streak INTEGER DEFAULT 0,
            last_active DATE,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        )
    """)
    
    # Check for missing columns (migration)
    cursor.execute("PRAGMA table_info(users)")
    columns = [row['name'] for row in cursor.fetchall()]
    
    if 'username' not in columns:
        cursor.execute("ALTER TABLE users ADD COLUMN username TEXT UNIQUE")
    if 'phone' not in columns:
        cursor.execute("ALTER TABLE users ADD COLUMN phone TEXT UNIQUE")

    # Schemes table
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS schemes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT,
            role_target TEXT,
            district_target TEXT,
            deadline DATE,
            eligibility_rules TEXT
        )
    """)

    # Market Data
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS market_data (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            crop TEXT NOT NULL,
            price REAL NOT NULL,
            date DATE NOT NULL
        )
    """)

    # OTPs
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS otps (
            email TEXT PRIMARY KEY,
            otp TEXT NOT NULL,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        )
    """)

    # Seed data
    cursor.execute("SELECT count(*) as count FROM schemes")
    if cursor.fetchone()['count'] == 0:
        cursor.execute("INSERT INTO schemes (title, description, role_target, district_target, deadline, eligibility_rules) VALUES (?, ?, ?, ?, ?, ?)",
            ('PM-Kisan Samman Nidhi', 'Income support of Rs. 6000/- per year to all landholding farmer families.', 'farmer', 'all', '2026-12-31', 'Small and marginal farmers'))
        cursor.execute("INSERT INTO schemes (title, description, role_target, district_target, deadline, eligibility_rules) VALUES (?, ?, ?, ?, ?, ?)",
            ('Rural Housing Scheme', 'Financial assistance for construction of houses in rural areas.', 'all', 'all', '2026-06-30', 'BPL families'))
    
    conn.commit()
    conn.close()
    print("Database initialized successfully (Python).")

if __name__ == "__main__":
    init_db()
