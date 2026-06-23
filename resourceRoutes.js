import express from "express";
import {
  calculateAndStore,
  getAllResources,
  getResourcesByDisasterId,
  getAllDisastersWithResources,
  recalculateResources,
  deleteResourceRecord,
  getDisastersWithoutResources,
  getMyResources,
} from "../controllers/resourcesController.js";
import { auth } from "../middleware/authMiddleware.js";
import { authorise } from "../middleware/rbacMiddleware.js";

const router = express.Router();

router.use(auth);

router.get(
  "/disasters/pending",
  authorise("ngo", "government"),
  getDisastersWithoutResources,
);

router.post("/calculate", authorise("ngo", "government"), calculateAndStore);

router.get("/", authorise("admin", "ngo", "government"), getAllResources);

router.get(
  "/disasters",
  authorise("admin", "ngo", "government"),
  getAllDisastersWithResources,
);

router.get("/my", authorise("ngo", "government"), getMyResources);

router.get(
  "/disaster/:disasterId",
  authorise("admin", "ngo", "government"),
  getResourcesByDisasterId,
);

router.patch(
  "/disaster/:disasterId/recalculate",
  authorise("ngo", "government"),
  recalculateResources,
);

router.delete(
  "/disaster/:disasterId",
  authorise("admin"),
  deleteResourceRecord,
);

export default router;
