
import { Router, Request, Response } from 'express';
import { getUserByEmail, updateUserProfile } from './dbService';

const router = Router();


// GET /profile?email=...
router.get('/profile', async (req: Request, res: Response) => {
  const { email } = req.query;
  if (!email || typeof email !== 'string') {
    return res.status(400).json({ error: 'Email is required' });
  }
  const user = getUserByEmail(email);
  if (!user) return res.status(404).json({ error: 'User not found' });
  return res.json(user);
});


// PUT /update?email=... { name, phone, address }
router.put('/update', async (req: Request, res: Response) => {
  const { email } = req.query;
  const { name, phone, address } = req.body;
  if (!email || typeof email !== 'string') {
    return res.status(400).json({ error: 'Email is required' });
  }
  const success = updateUserProfile(email, { name, phone, address });
  if (!success) return res.status(404).json({ error: 'User not found or not updated' });
  return res.json({ success: true });
});

export default router;
