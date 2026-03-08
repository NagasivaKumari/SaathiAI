
import { Router, Request, Response } from 'express';
import { readSchemesJson } from '../utils/readSchemesJson';

const router = Router();

// GET /schemes
router.get('/', async (req: Request, res: Response) => {
  const schemes = readSchemesJson();
  // Return only summary info for list
  const summary = schemes.map(s => ({
    id: s.id,
    name: s.name,
    category: s.category,
    description: s.description,
    benefit: s.benefit,
    status: s.status || 'Active'
  }));
  res.json(summary);
});

// GET /schemes/:scheme_id
router.get('/:scheme_id', async (req: Request, res: Response) => {
  const { scheme_id } = req.params;
  const schemes = readSchemesJson();
  const scheme = schemes.find(s => s.id === scheme_id);
  if (!scheme) {
    return res.status(404).json({ error: 'Scheme not found' });
  }
  res.json(scheme);
});

// GET /schemes/recommend
router.get('/recommend', async (req: Request, res: Response) => {
  // TODO: Replace with real recommendation logic
  res.json([
    { id: 1, name: 'PM Kisan Samman Nidhi', desc: '₹6000/year for eligible farmers', status: 'Active' }
  ]);
});


// Simple in-memory application store for demo
const userApplications: { [userId: string]: { schemeId: string, status: string, applicationData: any }[] } = {};

// POST /schemes/apply
router.post('/apply', async (req: Request, res: Response) => {
  const { userId, schemeId, applicationData } = req.body;
  if (!userId || !schemeId) {
    return res.status(400).json({ error: 'Missing userId or schemeId' });
  }
  if (!userApplications[userId]) userApplications[userId] = [];
  userApplications[userId].push({ schemeId, status: 'Pending', applicationData });
  res.json({ success: true, message: 'Application submitted', status: 'Pending' });
});


// GET /schemes/application-status?userId=xxx&schemeId=yyy
router.get('/application-status', async (req: Request, res: Response) => {
  const { userId, schemeId } = req.query;
  if (!userId || !schemeId) {
    return res.status(400).json({ error: 'Missing userId or schemeId' });
  }
  const apps = userApplications[userId as string] || [];
  const app = apps.find(a => a.schemeId === schemeId);
  if (!app) {
    return res.status(404).json({ error: 'No application found' });
  }
  res.json({ status: app.status, applicationData: app.applicationData });
});

// GET /schemes/applications
router.get('/applications', async (req: Request, res: Response) => {
  // TODO: Fetch all user applications
  res.json([{ id: 1, scheme: 'PM Kisan Samman Nidhi', status: 'Pending' }]);
});

export default router;
