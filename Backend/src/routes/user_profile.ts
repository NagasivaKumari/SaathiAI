import { Router, Request, Response } from 'express';

const router = Router();

// GET /user/profile
router.get('/profile', async (req: Request, res: Response) => {
  // TODO: Fetch user profile from DB
  res.json({ name: 'Sunil, Sanchi', email: 'sunil@example.com', points: 1200 });
});

// PUT /user/update
router.put('/update', async (req: Request, res: Response) => {
  // TODO: Update user profile in DB
  res.json({ success: true });
});

// GET /user/activity
router.get('/activity', async (req: Request, res: Response) => {
  // TODO: Fetch user activity from DB
  res.json([
    { type: 'scheme_applied', scheme: 'PM Kisan', date: '2026-03-01' },
    { type: 'skill_completed', skill: 'Dairy Management', date: '2026-02-28' }
  ]);
});

export default router;
