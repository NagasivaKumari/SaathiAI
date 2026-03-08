import express from "express";
import { GoogleGenAI } from "@google/genai";
import db from "../db";

const router = express.Router();

// AI Query
router.post("/query", async (req, res) => {
  const { query, userId, lang } = req.body;

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
      contents: `You are SathiAI, a friendly rural AI companion for rural India. 
      User Name: ${userName}.
      User Query: ${query}
      Language: ${lang || 'en-US'}
      
      Instructions:
      - Respond in the user's language (${lang || 'en-US'}). If Hindi, use simple, friendly Hindi with local idioms and analogies. If Marathi, use Marathi idioms. If Bengali, use Bengali idioms. If English, use simple rural English.
      - Always use a supportive, patient, and culturally aware tone, like a village mentor.
      - Break down complex processes into simple steps.
      - Suggest 2-3 follow-up actions relevant to rural users.
      - If the query is about government schemes, skills, or market, provide actionable advice.
      - If possible, use local analogies (e.g., farming, festivals, daily life).
      - Respond in JSON format:
      {
        "intent": "string",
        "confidence": number,
        "response": "string",
        "suggestions": ["string"]
      }
      `,
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

// Predictive/Proactive Recommendations
router.get("/predictive-recommendations", async (req, res) => {
  const { userId, lang } = req.query as { userId?: string; lang?: string };
  const now = new Date();
  const hour = now.getHours();
  const recommendations: { type: string; message: string }[] = [];

  if (hour < 12) {
    recommendations.push({
      type: "scheme",
      message:
        lang === "hi-IN"
          ? "आज प्रधानमंत्री किसान योजना के लिए आवेदन करें!"
          : "Apply for PM Kisan scheme today!",
    });
    recommendations.push({
      type: "skill",
      message:
        lang === "hi-IN"
          ? "नई कौशल सीखें: सिलाई या कंप्यूटर"
          : "Learn a new skill: tailoring or computers",
    });
  } else {
    recommendations.push({
      type: "market",
      message:
        lang === "hi-IN"
          ? "बाजार में प्याज के दाम बढ़ रहे हैं, बेचने का अच्छा समय है।"
          : "Onion prices are rising, good time to sell.",
    });
  }

  recommendations.push({
    type: "alert",
    message:
      lang === "hi-IN"
        ? "आपका अगला भुगतान 7 मार्च को है।"
        : "Your next payout is on March 7.",
  });

  res.json({ recommendations });
});

export default router;
