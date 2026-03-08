import { Router, Request, Response } from 'express';

const router = Router();

// GET /skills
router.get('/', async (req: Request, res: Response) => {
  // TODO: Replace with real DB query
  const skills = [
    { id: 1, name: 'Organic Farming', progress: 0.7, status: 'Continue' },
    { id: 2, name: 'Dairy Management', progress: 1.0, status: 'Completed' },
    { id: 3, name: 'Digital Payments', progress: 0.3, status: 'Start' },
  ];
  res.json(skills);
});

// GET /skills/:skill_id
router.get('/:skill_id', async (req: Request, res: Response) => {
  // TODO: Replace with real DB query
  const { skill_id } = req.params;
  res.json({ id: skill_id, name: 'Organic Farming', progress: 0.7, status: 'Continue' });
});

// POST /skills/start
router.post('/start', async (req: Request, res: Response) => {
  // TODO: Save start to DB
  res.json({ success: true, message: 'Skill started' });
});

// POST /skills/progress
router.post('/progress', async (req: Request, res: Response) => {
  // TODO: Update progress in DB
  res.json({ success: true, message: 'Progress updated' });
});

// GET /skills/progress
router.get('/progress', async (req: Request, res: Response) => {
  // TODO: Fetch progress from DB
  res.json([{ id: 1, progress: 0.7 }, { id: 2, progress: 1.0 }]);
});

// GET /skills/recommend
router.get('/recommend', async (req: Request, res: Response) => {
  // TODO: Replace with real recommendation logic
  res.json([{ id: 1, name: 'Organic Farming', progress: 0.7, status: 'Continue' }]);
});

// POST /skills/complete
router.post('/complete', async (req: Request, res: Response) => {
  // TODO: Mark skill as completed in DB
  res.json({ success: true, message: 'Skill completed' });
});

export default router;
