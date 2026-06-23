import express from "express";
import { predictAndSaveTech } from "../controllers/techDisasterController.js";
import { auth } from "../middleware/authMiddleware.js";
const router = express.Router();
 
router.post("/predict-and-save", auth, predictAndSaveTech);

export default router;