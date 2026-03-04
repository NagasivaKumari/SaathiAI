import express from "express";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import db from "../db";

const router = express.Router();
const JWT_SECRET = process.env.JWT_SECRET || "sathiai-secret-key";

// Register
router.post("/register", async (req, res) => {
  const { name, email, password, role, district } = req.body;
  console.log("Registering user:", email);

  try {
    const hashedPassword = await bcrypt.hash(password, 10);
    const stmt = db.prepare(
      "INSERT INTO users (name, email, password, role, district) VALUES (?, ?, ?, ?, ?)"
    );
    const result = stmt.run(name, email, hashedPassword, role || "farmer", district);
    
    const token = jwt.sign({ id: result.lastInsertRowid, email }, JWT_SECRET, {
      expiresIn: "24h",
    });

    res.status(201).json({ token, user: { id: result.lastInsertRowid, name, email, role, district } });
  } catch (error: any) {
    console.error("Registration error:", error);
    if (error.code === "SQLITE_CONSTRAINT") {
      return res.status(400).json({ error: "Email already exists" });
    }
    res.status(500).json({ error: "Registration failed: " + error.message });
  }
});

// Login
router.post("/login", async (req, res) => {
  const { email, password } = req.body;
  console.log("Login attempt:", email);

  try {
    const user = db.prepare("SELECT * FROM users WHERE email = ?").get(email) as any;
    if (!user || !(await bcrypt.compare(password, user.password))) {
      console.log("Invalid login for:", email);
      return res.status(401).json({ error: "Invalid credentials" });
    }

    const token = jwt.sign({ id: user.id, email: user.email }, JWT_SECRET, {
      expiresIn: "24h",
    });

    res.json({
      token,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
        district: user.district,
        points: user.points,
        level: user.level
      },
    });
  } catch (error: any) {
    console.error("Login error:", error);
    res.status(500).json({ error: "Login failed: " + error.message });
  }
});

// Profile
router.get("/profile", async (req, res) => {
  const authHeader = req.headers.authorization;
  if (!authHeader) return res.status(401).json({ error: "No token provided" });

  const token = authHeader.split(" ")[1];
  try {
    const decoded = jwt.verify(token, JWT_SECRET) as any;
    const user = db.prepare("SELECT id, name, email, role, district, points, level FROM users WHERE id = ?").get(decoded.id) as any;
    res.json(user);
  } catch (error) {
    res.status(401).json({ error: "Invalid token" });
  }
});

export default router;
