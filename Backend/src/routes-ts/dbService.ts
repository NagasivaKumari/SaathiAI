import Database from 'better-sqlite3';
import path from 'path';

const dbPath = path.resolve(__dirname, '../../sathiai.db');
const db = new Database(dbPath);

export function getUserByEmail(email: string) {
  const stmt = db.prepare('SELECT * FROM users WHERE email = ?');
  return stmt.get(email);
}

export function updateUserProfile(email: string, data: { name?: string; phone?: string; address?: string }) {
  const { name, phone, address } = data;
  const stmt = db.prepare('UPDATE users SET name = COALESCE(?, name), phone = COALESCE(?, phone), district = COALESCE(?, district) WHERE email = ?');
  const result = stmt.run(name, phone, address, email);
  return result.changes > 0;
}

export default db;
