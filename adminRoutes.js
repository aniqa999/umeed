import express from "express";
import {
  getAllUsers,
  getPendingUsers,
  getUserById,
  approveUser,
  rejectUser,
  suspendUser,
  reinstateUser,
  getActivityLogs,
  getUserActivityLogs,
  getPlatformStats,
  getAllDisasters,
  getDisasterById,
  getAllResources,
  getResourceById,
  getAllReports,
  getReportById,
} from "../controllers/adminController.js";
import { auth } from "../middleware/authMiddleware.js";
import { authorise } from "../middleware/rbacMiddleware.js";

const router = express.Router();

router.use(auth, authorise("admin"));

// Stats
router.get("/stats", getPlatformStats);

// Users
router.get("/users", getAllUsers);
router.get("/users/pending", getPendingUsers);
router.get("/users/:id", getUserById);
router.patch("/users/:id/approve", approveUser);
router.patch("/users/:id/reject", rejectUser);
router.patch("/users/:id/suspend", suspendUser);
router.patch("/users/:id/reinstate", reinstateUser);

// Disasters (Predictions)
router.get("/disasters", getAllDisasters);
router.get("/disasters/:id", getDisasterById);

// Resources
router.get("/resources", getAllResources);
router.get("/resources/:id", getResourceById);

// Reports
router.get("/reports", getAllReports);
router.get("/reports/:id", getReportById);

// Activity Logs
router.get("/logs", getActivityLogs);
router.get("/logs/user/:userId", getUserActivityLogs);

export default router;
