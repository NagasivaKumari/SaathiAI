import { Router, Request, Response } from 'express';

const router = Router();

// GET /alerts
router.get('/', async (req: Request, res: Response) => {
  // TODO: Fetch alerts from DB
  res.json([
    { id: 1, message: 'Scheme payout credited!', read: false },
    { id: 2, message: 'Apply for PM Kisan scheme today!', read: true }
  ]);
});

// POST /alerts/mark-read
router.post('/mark-read', async (req: Request, res: Response) => {
  // TODO: Mark alert as read in DB
  res.json({ success: true });
});

// POST /alerts/create
router.post('/create', async (req: Request, res: Response) => {
  // TODO: Create new alert in DB
  res.json({ success: true, id: 3 });
});

export default router;
