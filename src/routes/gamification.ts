import express from "express";
import db from "../db";

const router = express.Router();

// Leaderboard
router.get("/leaderboard", (req, res) => {
  const topUsers = db.prepare("SELECT name, points, level FROM users ORDER BY points DESC LIMIT 10").all();
  res.json(topUsers);
});

// User points and progress
router.get("/user/:userId", (req, res) => {
  const { userId } = req.params;
  const user = db.prepare("SELECT points, level, streak FROM users WHERE id = ?").get(userId);
  res.json(user);
});

// Add points (Internal/Action based)
router.post("/action", (req, res) => {
  const { userId, action } = req.body;
  
  let pointsToAdd = 0;
  switch (action) {
    case 'view_scheme': pointsToAdd = 10; break;
    case 'apply_scheme': pointsToAdd = 20; break;
    case 'complete_skill': pointsToAdd = 30; break;
    default: pointsToAdd = 5;
  }

  const user = db.prepare("SELECT points FROM users WHERE id = ?").get(userId) as any;
  if (!user) return res.status(404).json({ error: "User not found" });

  const newPoints = user.points + pointsToAdd;
  const newLevel = Math.floor(newPoints / 100) + 1;

  db.prepare("UPDATE users SET points = ?, level = ? WHERE id = ?").run(newPoints, newLevel, userId);

  res.json({ points: newPoints, level: newLevel, added: pointsToAdd });
});

export default router;
