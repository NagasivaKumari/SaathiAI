import { Router, Request, Response } from 'express';

const router = Router();

// GET /user/dashboard
router.get('/dashboard', async (req: Request, res: Response) => {
  // TODO: Replace with real DB/user logic
  // Example: get userId from req.user (after auth middleware)
  const userId = req.user?.id || 1;

  // Fetch user info, badges, quick actions from DB
  // Replace with real queries
  const user = {
    name: 'Sunil, Sanchi',
    points: 1200,
    nextPayout: '2026-03-07',
    nextScheme: '2026-03-04T16:30:00',
  };
  const badges = [
    { icon: 'emoji_events', label: 'Gold Badge', desc: 'Scheme Seeker' },
    { icon: 'star', label: 'Skill Starter', desc: 'Started a skill' },
  ];
  const quickActions = [
    { icon: 'mic', label: 'Ask Sathi' },
    { icon: 'school', label: 'Skills' },
    { icon: 'account_balance', label: 'Schemes' },
    { icon: 'shopping_basket', label: 'Market' },
  ];

  res.json({ user, badges, quickActions });
});

export default router;
