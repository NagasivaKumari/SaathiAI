import { Router, Request, Response } from 'express';

const router = Router();

// POST /sync
router.post('/', async (req: Request, res: Response) => {
  // TODO: Sync data from client
  res.json({ success: true });
});

// GET /sync/status
router.get('/status', async (req: Request, res: Response) => {
  // TODO: Return sync status
  res.json({ status: 'Up to date', lastSync: '2026-03-04T10:30:00' });
});

export default router;
