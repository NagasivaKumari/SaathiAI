import express from "express";
import { createServer as createViteServer } from "vite";
import path from "path";
import cors from "cors";
import dotenv from "dotenv";
import { initDB } from "./src/db";
import authRoutes from "./src/routes/auth";
import aiRoutes from "./src/routes/ai";
import marketRoutes from "./src/routes/market";
import gamificationRoutes from "./src/routes/gamification";
import userRoutes from "./src/routes/user";
import schemesRoutes from "./src/routes/schemes";
import skillsRoutes from "./src/routes/skills";
import alertsRoutes from "./src/routes/alerts";
import syncRoutes from "./src/routes/sync";
import userProfileRoutes from "./src/routes/user_profile";
import { startScheduler } from "./src/services/scheduler";

// Load environment variables
dotenv.config();

async function startServer() {
  const app = express();
  const PORT = 3000;

  // Initialize Database
  initDB();

  // Middleware
  app.use(cors());
  app.use(express.json());

  // API Routes
  app.use("/api/auth", authRoutes);
  app.use("/api/ai", aiRoutes);
  app.use("/api/market", marketRoutes);
  app.use("/api/gamification", gamificationRoutes);
  app.use("/api/user", userRoutes);
  app.use("/api/schemes", schemesRoutes);
  app.use("/api/skills", skillsRoutes);
  app.use("/api/alerts", alertsRoutes);
  app.use("/api/sync", syncRoutes);
  app.use("/api/user_profile", userProfileRoutes);

  // Health check
  app.get("/api/health", (req, res) => {
    res.json({ status: "ok" });
  });

  // Start Scheduler
  startScheduler();

  // Vite middleware for development
  if (process.env.NODE_ENV !== "production") {
    const vite = await createViteServer({
      server: { middlewareMode: true },
      appType: "spa",
    });
    app.use(vite.middlewares);
  } else {
    app.use(express.static(path.resolve(__dirname, "dist")));
    app.get("*", (req, res) => {
      res.sendFile(path.resolve(__dirname, "dist", "index.html"));
    });
  }

  app.listen(PORT, "0.0.0.0", () => {
    console.log(`SathiAI Server running on http://localhost:${PORT}`);
  });
}

startServer().catch((err) => {
  console.error("Failed to start server:", err);
});
