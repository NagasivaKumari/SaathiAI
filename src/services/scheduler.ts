import cron from "node-cron";
import db from "../db";

export function startScheduler() {
  // Daily deadline check (at midnight)
  cron.schedule("0 0 * * *", () => {
    console.log("Running daily deadline check...");
    const schemes = db.prepare("SELECT id, title, deadline FROM schemes WHERE deadline <= date('now', '+7 days')").all() as any[];
    
    schemes.forEach(scheme => {
      // Alert all relevant users (simplified: alert all for now)
      const users = db.prepare("SELECT id FROM users").all() as any[];
      users.forEach(user => {
        db.prepare("INSERT INTO alerts (user_id, message, type) VALUES (?, ?, ?)")
          .run(user.id, `Deadline approaching for ${scheme.title}: ${scheme.deadline}`, 'deadline');
      });
    });
  });

  // Weekly skill reminder (Mondays at 9 AM)
  cron.schedule("0 9 * * 1", () => {
    console.log("Running weekly skill reminder...");
    const users = db.prepare("SELECT id FROM users").all() as any[];
    users.forEach(user => {
      db.prepare("INSERT INTO alerts (user_id, message, type) VALUES (?, ?, ?)")
        .run(user.id, "Don't forget to check out new skills to earn points!", 'reminder');
    });
  });

  console.log("SathiAI Scheduler started.");
}
