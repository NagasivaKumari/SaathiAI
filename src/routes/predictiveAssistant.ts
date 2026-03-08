// predictiveAssistant.ts
// Suggests schemes, skills, and market info based on user profile, location, and activity

import db from "../db";

export class PredictiveAssistant {
  static getRecommendations({ userId, district, role }) {
    // Recommend schemes
    const schemes = db.prepare(`
      SELECT * FROM schemes 
      WHERE (role_target = ? OR role_target = 'all')
      AND (district_target = ? OR district_target = 'all')
      ORDER BY deadline ASC
      LIMIT 2
    `).all(role, district);

    // Recommend skills
    const skills = db.prepare(`
      SELECT * FROM skills 
      WHERE (target_role = ? OR target_role = 'all')
      LIMIT 2
    `).all(role);

    // Recommend market info (stubbed)
    const market = [
      { crop: "Wheat", price: 2200, trend: "rising" },
      { crop: "Tomato", price: 1800, trend: "stable" }
    ];

    return {
      schemes,
      skills,
      market
    };
  }
}
