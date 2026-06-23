import jwt from "jsonwebtoken";
import User from "../models/userModel.js";
import ActivityLog from "../models/activityLogModel.js";
import crypto from "crypto";
import {
  validateCnic,
  validateEmail,
  validatePassword,
} from "../utils/signin_validation.js";
import { sendResetMail } from "../services/emailService.js";
import cloudinary from "../config/cloudinary.js";

const signToken = (user) =>
  jwt.sign(
    { id: user._id, role: user.role, status: user.status },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN || "7d" },
  );

const sendTokenResponse = (user, statusCode, res) => {
  const token = signToken(user);

  res.cookie("token", token, {
    httpOnly: true,
    secure: process.env.NODE_ENV === "production",
    sameSite: "strict",
    maxAge: 7 * 24 * 60 * 60 * 1000,
  });

  res.status(statusCode).json({
    success: true,
    token,
    user: user.toPublicJSON(),
  });
};

const signup = async (req, res) => {
  try {
    const {
      fullName,
      email,
      password,
      role,
      organization,
      phone,
      cnic,
      province,
      designation,
      department,
      websiteLink,
      experience,
      country,
      district,
      city,
      area,
      currentAddress,
    } = req.body;

    if (!["ngo", "government"].includes(role)) {
      return res.status(400).json({
        success: false,
        message: 'Role must be "ngo" or "government".',
      });
    }

    const emailError = validateEmail(email, role);
    if (emailError) {
      return res.status(400).json({ success: false, message: emailError });
    }

    const passwordError = validatePassword(password);
    if (passwordError) {
      return res.status(400).json({ success: false, message: passwordError });
    }

    if (!organization) {
      return res.status(400).json({
        success: false,
        message: "Organization is required.",
      });
    }

    if (!phone) {
      return res.status(400).json({
        success: false,
        message: "Contact number is required.",
      });
    }

    if (!province) {
      return res.status(400).json({
        success: false,
        message: "Province is required.",
      });
    }

    if (!cnic) {
      return res.status(400).json({
        success: false,
        message: "CNIC number is required.",
      });
    }

    const cnicError = validateCnic(cnic);
    if (cnicError) {
      return res.status(400).json({ success: false, message: cnicError });
    }

    const existing = await User.findOne({ email: email?.toLowerCase().trim() });
    if (existing) {
      return res.status(409).json({
        success: false,
        message: "An account with this email already exists.",
      });
    }

    const user = await User.create({
      fullName,
      email,
      password,
      role,
      organization,
      phone,
      cnic,
      province,
      designation,
      department,
      websiteLink,
      experience,
      country: country || "Pakistan",
      district,
      city,
      area,
      currentAddress,
    });

    await ActivityLog.log({
      userId: user._id,
      userRole: user.role,
      category: "auth",
      action: "SIGNUP",
      target: { model: "User", id: user._id },
      description: `New ${role} account registered - pending admin approval`,
      req,
      statusCode: 201,
      success: true,
    });

    res.status(201).json({
      success: true,
      message:
        "Registration successful. Your account is pending admin approval. You will be notified once approved.",
      userId: user._id,
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: "Email and password are required.",
      });
    }

    const user = await User.findOne({
      email: email.toLowerCase().trim(),
    }).select("+password");

    if (!user || !(await user.comparePassword(password))) {
      if (user) {
        await ActivityLog.log({
          userId: user._id,
          userRole: user.role,
          category: "auth",
          action: "LOGIN_FAILED",
          description: "Incorrect password",
          req,
          statusCode: 401,
          success: false,
          errorMessage: "Incorrect password",
        });
      }

      return res.status(401).json({
        success: false,
        message: "Invalid email or password.",
      });
    }

    if (!user.canLogin()) {
      const messages = {
        pending: "Your account is awaiting admin approval.",
        rejected:
          "Your account registration was rejected. Please contact support.",
        suspended:
          "Your account has been suspended. Please contact the administrator.",
      };

      await ActivityLog.log({
        userId: user._id,
        userRole: user.role,
        category: "auth",
        action: "LOGIN_FAILED",
        description: `Login blocked - account status: ${user.status}`,
        req,
        statusCode: 403,
        success: false,
        errorMessage: messages[user.status],
      });

      return res.status(403).json({
        success: false,
        message: messages[user.status] || "Access denied.",
      });
    }

    user.lastLogin = new Date();
    await user.save({ validateBeforeSave: false });

    await ActivityLog.log({
      userId: user._id,
      userRole: user.role,
      category: "auth",
      action: "LOGIN",
      description: `${user.role} logged in`,
      req,
      statusCode: 200,
      success: true,
    });

  sendTokenResponse(user, 200, res);
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};  

const logout = async (req, res) => {
  try {
    await ActivityLog.log({
      userId: req.user._id,
      userRole: req.user.role,
      category: "auth",
      action: "LOGOUT",
      description: `${req.user.role} logged out`,
      req,
      statusCode: 200,
      success: true,
    });

    res.cookie("token", "", {
      httpOnly: true,
      expires: new Date(0),
    });

    res.json({ success: true, message: "Logged out successfully." });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

const getMe = async (req, res) => {
  try {
    const user = await User.findById(req.user._id);

    if (!user) {
      return res
        .status(404)
        .json({ success: false, message: "User not found." });
    }

    res.json({ success: true, user: user.toPublicJSON() });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

const changePassword = async (req, res) => {
  try {
    const { currentPassword, newPassword } = req.body;

    if (!currentPassword || !newPassword) {
      return res.status(400).json({
        success: false,
        message: "currentPassword and newPassword are required.",
      });
    }

    if (newPassword.length < 8) {
      return res.status(400).json({
        success: false,
        message: "New password must be at least 8 characters.",
      });
    }

    const user = await User.findById(req.user._id).select("+password");

    if (!(await user.comparePassword(currentPassword))) {
      await ActivityLog.log({
        userId: user._id,
        userRole: user.role,
        category: "auth",
        action: "PASSWORD_CHANGED",
        description: "Password change failed — incorrect current password",
        req,
        statusCode: 401,
        success: false,
        errorMessage: "Incorrect current password",
      });

      return res.status(401).json({
        success: false,
        message: "Current password is incorrect.",
      });
    }

    user.password = newPassword;
    await user.save();

    await ActivityLog.log({
      userId: user._id,
      userRole: user.role,
      category: "auth",
      action: "PASSWORD_CHANGED",
      description: "Password changed successfully",
      req,
      statusCode: 200,
      success: true,
    });

    res.json({ success: true, message: "Password changed successfully." });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

const updateProfile = async (req, res) => {
  try {
    const allowedFields = [
      "fullName",
      "phone",
      "organization",
      "designation",
      "department",
      "websiteLink",
      "experience",
      "cnic",
      "country",
      "province",
      "district",
      "city",
      "area",
      "currentAddress",
    ];

    const updates = {};
    allowedFields.forEach((field) => {
      if (req.body[field] !== undefined) updates[field] = req.body[field];
    });

    if (req.file) {
      const b64 = Buffer.from(req.file.buffer).toString("base64");
      const dataURI = `data:${req.file.mimetype};base64,${b64}`;

      const result = await cloudinary.uploader.upload(dataURI, {
        folder: "profile_images",
        width: 500,
        height: 500,
        crop: "fill",
        gravity: "face",
      });

      updates.profileImage = result.secure_url;

      const user = await User.findById(req.user._id);
      if (user.profileImage) {
        const publicId = user.profileImage.split("/").pop().split(".")[0];
        await cloudinary.uploader.destroy(`profile_images/${publicId}`);
      }
    }

    if (Object.keys(updates).length === 0) {
      return res.status(400).json({
        success: false,
        message: "No valid fields provided for update.",
      });
    }

    const user = await User.findByIdAndUpdate(req.user._id, updates, {
      returnDocument: "after",
      runValidators: true,
    });

    await ActivityLog.log({
      userId: user._id,
      userRole: user.role,
      category: "user",
      action: "PROFILE_UPDATED",
      target: { model: "User", id: user._id },
      description: `Profile updated — fields: ${Object.keys(updates).join(", ")}`,
      req,
      statusCode: 200,
      success: true,
      metadata: { updatedFields: Object.keys(updates) },
    });

    res.json({ success: true, user: user.toPublicJSON() });
  } catch (error) {
    if (error.message.includes("image files")) {
      return res.status(400).json({ success: false, message: error.message });
    }
    res.status(500).json({ success: false, message: error.message });
  }
};

const resetPassword = async (req, res) => {
  try {
    const { currentPassword, newPassword, confirmPassword } = req.body;
    const user = await User.findById(req.user._id).select("+password");
    if (!user) return res.status(404).json({ message: "User not found" });

    if (
      !(await user.comparePassword(currentPassword)) ||
      newPassword !== confirmPassword
    ) {
      if (user) {
        await ActivityLog.log({
          userId: user._id,
          userRole: user.role,
          category: "auth",
          action: "RESET_PASSWORD_FAILED",
          description: "Incorrect password",
          req,
          statusCode: 401,
          success: false,
          errorMessage: "Incorrect password",
        });
      }

      return res.status(401).json({
        success: false,
        message: "Invalid password.",
      });
    }

    user.password = newPassword;
    await user.save();

    await ActivityLog.log({
      userId: user._id,
      userRole: user.role,
      category: "auth",
      action: "RESET_PASSWORD",
      description: `${user.fullName} password reset successfully`,
      req,
      statusCode: 200,
      success: true,
    });

    console.log(user);
    res
      .status(200)
      .json({ success: true, message: "Password reset successful" });
  } catch (e) {
    res.status(500).json({ message: "Failed to reset password" });
  }
};

const forgotPassword = async (req, res) => {
  try {
    const { email } = req.body;
    const user = await User.findOne({ email });
    if (!user) {
      await ActivityLog.log({
        userId: null,
        category: "auth",
        action: "FORGOT_PASSWORD",
        description: "User not found",
        req,
        statusCode: 404,
        success: false,
      });
      return res.status(404).send("User not found");
    }

    const resetToken = crypto.randomBytes(32).toString("hex");
    const hashedToken = crypto
      .createHash("sha256")
      .update(resetToken)
      .digest("hex");

    user.resetPasswordToken = hashedToken;
    user.resetPasswordExpires = Date.now() + 60 * 60 * 1000;
    await user.save();

    const url = `http://localhost:8080/api/auth/reset-password/${resetToken}`;

    sendResetMail(user.email, user.name, url);

    await ActivityLog.log({
      userId: user._id,
      category: "auth",
      action: "FORGOT_PASSWORD",
      description: `${user._id} password link sent successfully`,
      req,
      statusCode: 200,
      success: true,
    });

    res.status(200).json({ message: "Reset link sent to email." });
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
};

const resetForgotPassword = async (req, res) => {
  try {
    const { resetToken } = req.params;
    const hashedToken = crypto
      .createHash("sha256")
      .update(resetToken)
      .digest("hex");

    const user = await User.findOne({
      resetPasswordToken: hashedToken,
      resetPasswordExpires: { $gt: Date.now() },
    });
    if (!user) {
      await ActivityLog.log({
        userId: null,
        category: "auth",
        action: "CHANGE_PASSWORD_FAILED",
        description:
          "User not found or token expired password change attempt failed",
        req,
        statusCode: 400,
        success: false,
      });

      return res.status(400).send("Token is invalid or has expired.");
    }

    user.password = req.body.password;
    user.resetPasswordToken = undefined;
    user.resetPasswordExpires = undefined;
    await user.save();

    await ActivityLog.log({
      userId: user._id,
      category: "auth",
      action: "CHANGE_PASSWORD_SUCCESSFUL",
      description: `${user._id} password changed successfully`,
      req,
      statusCode: 200,
      success: true,
    });

    res.status(200).send("Password updated successfully.");
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
};

export {
  signup,
  login,
  logout,
  getMe,
  changePassword,
  updateProfile,
  resetPassword,
  forgotPassword,
  resetForgotPassword,
};
