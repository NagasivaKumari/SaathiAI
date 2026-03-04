import Database from 'better-sqlite3';
import path from 'path';

const db = new Database('sathiai.db');

export function initDB() {
  // Users table
  db.exec(`
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      email TEXT UNIQUE NOT NULL,
      password TEXT NOT NULL,
      role TEXT DEFAULT 'farmer',
      district TEXT,
      points INTEGER DEFAULT 0,
      level INTEGER DEFAULT 1,
      streak INTEGER DEFAULT 0,
      last_active DATE,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )
  `);

  // Schemes table
  db.exec(`
    CREATE TABLE IF NOT EXISTS schemes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      description TEXT,
      role_target TEXT,
      district_target TEXT,
      deadline DATE,
      eligibility_rules TEXT
    )
  `);

  // Market Data table
  db.exec(`
    CREATE TABLE IF NOT EXISTS market_data (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      crop TEXT NOT NULL,
      price REAL NOT NULL,
      date DATE NOT NULL
    )
  `);

  // Alerts table
  db.exec(`
    CREATE TABLE IF NOT EXISTS alerts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER,
      message TEXT NOT NULL,
      type TEXT,
      is_read INTEGER DEFAULT 0,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY(user_id) REFERENCES users(id)
    )
  `);

  // Skills table
  db.exec(`
    CREATE TABLE IF NOT EXISTS skills (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      description TEXT,
      points_reward INTEGER DEFAULT 30
    )
  `);

  // User Skills progress
  db.exec(`
    CREATE TABLE IF NOT EXISTS user_skills (
      user_id INTEGER,
      skill_id INTEGER,
      status TEXT DEFAULT 'not_started',
      progress INTEGER DEFAULT 0,
      PRIMARY KEY(user_id, skill_id),
      FOREIGN KEY(user_id) REFERENCES users(id),
      FOREIGN KEY(skill_id) REFERENCES skills(id)
    )
  `);

  // Seed some data if empty
  const schemeCount = db.prepare('SELECT count(*) as count FROM schemes').get() as { count: number };
  if (schemeCount.count === 0) {
    db.prepare('INSERT INTO schemes (title, description, role_target, district_target, deadline, eligibility_rules) VALUES (?, ?, ?, ?, ?, ?)').run(
      'PM-Kisan Samman Nidhi',
      'Income support of Rs. 6000/- per year to all landholding farmer families.',
      'farmer',
      'all',
      '2026-12-31',
      'Small and marginal farmers'
    );
    db.prepare('INSERT INTO schemes (title, description, role_target, district_target, deadline, eligibility_rules) VALUES (?, ?, ?, ?, ?, ?)').run(
      'Rural Housing Scheme',
      'Financial assistance for construction of houses in rural areas.',
      'all',
      'all',
      '2026-06-30',
      'BPL families'
    );
  }

  const skillCount = db.prepare('SELECT count(*) as count FROM skills').get() as { count: number };
  if (skillCount.count === 0) {
    db.prepare('INSERT INTO skills (title, description, points_reward) VALUES (?, ?, ?)').run(
      'Organic Farming Basics',
      'Learn how to transition to organic farming practices.',
      30
    );
    db.prepare('INSERT INTO skills (title, description, points_reward) VALUES (?, ?, ?)').run(
      'Drip Irrigation Setup',
      'Step-by-step guide to installing drip irrigation.',
      50
    );
  }
}

export default db;
