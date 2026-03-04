import { describe, it, expect, beforeAll } from 'vitest';
import bcrypt from 'bcryptjs';
import db, { initDB } from '../src/db';

describe('SathiAI Backend Logic', () => {
  beforeAll(() => {
    initDB();
  });

  it('should hash passwords correctly', async () => {
    const password = 'testpassword';
    const hashed = await bcrypt.hash(password, 10);
    const match = await bcrypt.compare(password, hashed);
    expect(match).toBe(true);
  });

  it('should store and retrieve users', () => {
    const email = `test-${Date.now()}@example.com`;
    db.prepare('INSERT INTO users (name, email, password) VALUES (?, ?, ?)').run('Test User', email, 'hashed');
    const user = db.prepare('SELECT * FROM users WHERE email = ?').get(email) as any;
    expect(user.name).toBe('Test User');
  });

  it('should calculate levels correctly', () => {
    const points = 250;
    const level = Math.floor(points / 100) + 1;
    expect(level).toBe(3);
  });
});
