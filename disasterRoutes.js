import express from "express";
import {
  createDisaster,
  getAllDisasters,
  getDisasterById,
  getFilteredDisasters,
  getMonthlyStats,
  updateDisaster,
  deleteDisaster,
  predictAndSave,
  getMyDisasters,
} from "../controllers/disasterController.js";
import { auth } from "../middleware/authMiddleware.js";
import { authorise } from "../middleware/rbacMiddleware.js";

const router = express.Router();

router.use(auth);

router.get("/filter", getFilteredDisasters);
router.get("/stats/monthly", getMonthlyStats);
router.get("/", getAllDisasters);
router.get("/my-disaster", authorise("ngo", "government"), getMyDisasters);
router.get("/:id", getDisasterById);

router.post("/", authorise("admin", "ngo", "government"), createDisaster);
router.patch("/:id", authorise("admin"), updateDisaster);
router.delete("/:id", authorise("admin"), deleteDisaster);

router.post(
  "/predict-and-save",
  authorise("admin", "government", "ngo"),
  predictAndSave,
);

export default router;
