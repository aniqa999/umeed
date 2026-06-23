import path from "path";
import { fileURLToPath } from "url";

import express from "express";
const router = express.Router();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// router.get('/reset-password', (req, res) => {
//   res.sendFile(path.join(__dirname, 'public', 'reset-password.html'));
// });

router.get("/reset-password/:token", (req, res) => {
  res.sendFile(path.join(__dirname, "..", "public", "reset_password.html"));
});

export default router;
