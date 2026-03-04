import express from "express";
import { GoogleGenAI } from "@google/genai";
import db from "../db";

const router = express.Router();

// AI Query
router.post("/query", async (req, res) => {
  const { query, userId } = req.body;

  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey || apiKey === "MY_GEMINI_API_KEY") {
    console.error("Invalid or missing GEMINI_API_KEY:", apiKey ? "Placeholder detected" : "Missing");
    return res.status(500).json({ error: "Gemini API key not configured correctly" });
  }

  const ai = new GoogleGenAI({ apiKey });
  
  try {
    const user = userId ? db.prepare("SELECT name FROM users WHERE id = ?").get(userId) as any : null;
    const userName = user ? user.name : "Friend";

    const response = await ai.models.generateContent({
      model: "gemini-2.0-flash",
      contents: `You are SathiAI, a friendly rural assistant. 
      User Name: ${userName}.
      User Query: ${query}
      
      Tasks:
      1. Identify the intent (e.g., farming_advice, scheme_info, market_query, general_help).
      2. Provide a friendly, encouraging response in simple steps.
      3. Suggest 2-3 follow-up actions.
      
      Respond in JSON format:
      {
        "intent": "string",
        "confidence": number,
        "response": "string",
        "suggestions": ["string"]
      }`,
      config: {
        responseMimeType: "application/json"
      }
    });

    let result;
    try {
      const text = response.text || "{}";
      // Remove markdown code blocks if present
      const cleanText = text.replace(/```json\n?|\n?```/g, "").trim();
      result = JSON.parse(cleanText);
    } catch (parseError) {
      console.error("AI Response Parse Error:", parseError, response.text);
      result = {
        intent: "general_help",
        confidence: 0.5,
        response: response.text || "I'm sorry, I couldn't process that request correctly.",
        suggestions: ["Try asking something else", "Check market prices"]
      };
    }
    res.json(result);
  } catch (error) {
    console.error("AI Query Error:", error);
    res.status(500).json({ error: "AI processing failed" });
  }
});

// Scheme Recommendation
router.get("/recommendations", async (req, res) => {
  const { userId } = req.query;
  
  try {
    const user = db.prepare("SELECT role, district FROM users WHERE id = ?").get(userId) as any;
    if (!user) return res.status(404).json({ error: "User not found" });

    // Simple matching logic
    const schemes = db.prepare(`
      SELECT * FROM schemes 
      WHERE (role_target = ? OR role_target = 'all')
      AND (district_target = ? OR district_target = 'all')
      ORDER BY deadline ASC
      LIMIT 3
    `).all(user.role, user.district);

    res.json(schemes);
  } catch (error) {
    res.status(500).json({ error: "Failed to get recommendations" });
  }
});

export default router;
