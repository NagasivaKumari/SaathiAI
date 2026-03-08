import express from "express";
import db from "../db";

const router = express.Router();


// Get current prices (integrate Agmarknet public API)
import axios from "axios";
router.get("/prices", async (req, res) => {
  try {
    // Example: fetch onion prices from Agmarknet
    const crop = req.query.crop || "Onion";
    const url = `https://api.data.gov.in/resource/9ef84268-d588-465a-a308-a864a43d0070?api-key=YOUR_API_KEY&format=json&filters[crop]=${encodeURIComponent(crop)}`;
    const response = await axios.get(url);
    const prices = response.data.records || [];
    res.json(prices);
  } catch (err) {
    // fallback to local DB if API fails
    const prices = db.prepare("SELECT * FROM market_data ORDER BY date DESC LIMIT 20").all();
    res.json(prices);
  }
});

// Predict prices (Simplified logic using Gemini or simple trend)
router.post("/predict", async (req, res) => {
  const { crop } = req.body;
  
  // In a real app, we'd use Prophet. Here we'll simulate or use Gemini.
  // Let's use a simple trend for now.
  const historical = db.prepare("SELECT price FROM market_data WHERE crop = ? ORDER BY date DESC LIMIT 7").all(crop) as any[];
  
  let basePrice = historical.length > 0 ? historical[0].price : 2000;
  const forecast = [];
  for (let i = 1; i <= 7; i++) {
    basePrice += (Math.random() - 0.4) * 50; // Slight upward bias
    forecast.push({ day: i, price: Math.round(basePrice) });
  }

  const recommendation = forecast[6].price > forecast[0].price 
    ? "Prices are expected to rise. Consider holding your stock." 
    : "Prices might stabilize or dip. Good time to sell if you have immediate needs.";

  res.json({ crop, forecast, recommendation });
});

export default router;
