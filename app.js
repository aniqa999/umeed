import cors from "cors";
import path from "path";
import helmet from "helmet";
import morgan from "morgan";
import express from "express";
import mongoose from "mongoose";
import { config } from "dotenv";
import { fileURLToPath } from "url";
import { expand } from "dotenv-expand";
import cookieParser from "cookie-parser";

import authRoutes from "./routes/authRoutes.js";
import userRoutes from "./routes/userRoutes.js";
import adminRoutes from "./routes/adminRoutes.js";
import reportRoutes from "./routes/reportRoutes.js";
import resourceRoutes from "./routes/resourceRoutes.js";
import disasterRoutes from "./routes/disasterRoutes.js";
import techDisasterRoutes from "./routes/techDisasterRoutes.js";
import resetPasswordRoutes from "./routes/resetPasswordRoutes.js";

expand(config());

const app = express();
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

app.use(helmet());
app.use(cors());
app.use(morgan("dev"));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, "public")));

app.use("/api/auth", authRoutes);
app.use("/api/users", userRoutes);
app.use("/api/auth", resetPasswordRoutes);
app.use("/api/admin", adminRoutes);
app.use("/api/disasters", disasterRoutes);
app.use("/api/tech-disasters", techDisasterRoutes);
app.use("/api/resources", resourceRoutes);
app.use("/api/reports", reportRoutes);

app.get("/api/health", (_req, res) =>
  res.json({ status: "ok", timestamp: new Date().toISOString() }),
);

app.use((_req, res) => {
  res.status(404).json({ success: false, message: "Route not found." });
});

app.use((err, _req, res, _next) => {
  console.error("[Global Error]", err);
  res.status(err.statusCode || 500).json({
    success: false,
    message: err.message || "Internal server error.",
  });
});

const PORT = process.env.PORT || 8080;
const MONGO = process.env.MONGO_URI;

if (!MONGO) {
  console.error("FATAL: MONGO_URI is not defined in environment variables.");
  process.exit(1);
}

mongoose
  .connect(MONGO)
  .then(() => {
    console.log("MongoDB connected.");
    app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
  })
  .catch((err) => {
    console.error("MongoDB connection failed:", err.message);
    process.exit(1);
  });

export default app;
