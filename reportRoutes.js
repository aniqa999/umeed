import express from "express";
import {
  generateReport,
  getAllReports,
  getReportById,
  getReportsByDisaster,
  downloadReport,
  updateReportNotes,
  archiveReport,
  deleteReport,
} from "../controllers/reportsController.js";
import { auth } from "../middleware/authMiddleware.js";
import { authorise } from "../middleware/rbacMiddleware.js";

const router = express.Router();

router.use(auth);

const allRoles = authorise("admin", "ngo", "government");

router.post("/generate", allRoles, generateReport);

router.get("/", allRoles, getAllReports);
router.get("/disaster/:disasterId", allRoles, getReportsByDisaster);
router.get("/:id", allRoles, getReportById);

router.post("/:id/download", allRoles, downloadReport);

router.patch("/:id/notes", allRoles, updateReportNotes);

router.patch("/:id/archive", authorise("admin"), archiveReport);
router.delete("/:id", authorise("admin"), deleteReport);

export default router;
