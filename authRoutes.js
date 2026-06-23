import express from "express";
import {
  signup,
  login,
  logout,
  getMe,
  changePassword,
  updateProfile,
  resetPassword,
  forgotPassword,
  resetForgotPassword,
} from "../controllers/authController.js";
import { auth } from "../middleware/authMiddleware.js";
import upload from "../middleware/upload.js";

const router = express.Router();

router.post("/signup", signup);
router.post("/login", login);

router.route("/reset-password/:resetToken").patch(resetForgotPassword);

router.route("/forgot-password").post(forgotPassword);

router.post("/logout", auth, logout);
router.get("/me", auth, getMe);
router.patch("/change-password", auth, changePassword);
router.patch(
  "/update-profile",
  auth,
  upload.single("profileImage"),
  updateProfile,
);
router.patch("/reset-password", auth, resetPassword);

export default router;
