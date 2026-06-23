import jwt from "jsonwebtoken";
import User from "../models/userModel.js";

const auth = async (req, res, next) => {
  try {
    let token;    

    if (
      req.headers.authorization &&
      req.headers.authorization.startsWith("Bearer ")
    ) {
      token = req.headers.authorization.split(" ")[1];
    } else if (req.cookies?.token) {
      token = req.cookies.token;
    }

    if (!token) {
      return res.status(401).json({
        success: false,
        message: "Authentication required. Please log in.",
      });
    }

    let decoded;
    try {
      decoded = jwt.verify(token, process.env.JWT_SECRET);
    } catch (err) {
      const message =
        err.name === "TokenExpiredError"
          ? "Your session has expired. Please log in again."
          : "Invalid token. Please log in again.";
      return res.status(401).json({ success: false, message });
    }

    const user = await User.findById(decoded.id);

    if (!user) {
      return res.status(401).json({
        success: false,
        message: "The account belonging to this token no longer exists.",
      });
    }

    if (!user.canLogin()) {
      const messages = {
        pending: "Your account is pending admin approval.",
        rejected: "Your account has been rejected.",
        suspended: "Your account has been suspended.",
      };
      return res.status(403).json({
        success: false,
        message: messages[user.status] || "Access denied.",
      });
    }

    req.user = user;
    next();
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export { auth };
