import mongoose from "mongoose";

const activityLogSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },

    userRole: {
      type: String,
      enum: ["admin", "ngo", "government"],
      required: true,
    },

    category: {
      type: String,
      enum: ["auth", "disaster", "resource", "report", "user"],
      required: true,
    },

    action: {
      type: String,
      required: true,
      uppercase: true,
      trim: true,
    },

    target: {
      model: {
        type: String,
        enum: ["DisasterEvent", "Resources", "Report", "User", null],
        default: null,
      },
      id: {
        type: mongoose.Schema.Types.ObjectId,
        default: null,
      },
    },

    description: {
      type: String,
      trim: true,
    },

    endpoint: {
      method: { type: String, uppercase: true },
      path: { type: String },
    },

    ipAddress: {
      type: String,
      trim: true,
    },

    userAgent: {
      type: String,
    },

    statusCode: {
      type: Number,
    },

    success: {
      type: Boolean,
      default: true,
    },

    errorMessage: {
      type: String,
      default: null,
    },

    metadata: {
      type: mongoose.Schema.Types.Mixed,
      default: null,
    },
  },
  {
    timestamps: true,
    versionKey: false,
  },
);

activityLogSchema.index({ userId: 1, createdAt: -1 });
activityLogSchema.index({ category: 1, action: 1 });
activityLogSchema.index({ "target.model": 1, "target.id": 1 });
activityLogSchema.index({ createdAt: -1 });
activityLogSchema.index(
  { createdAt: 1 },
  { expireAfterSeconds: 365 * 24 * 3600 },
);

activityLogSchema.statics.log = async function ({
  userId,
  userRole,
  category,
  action,
  target = {},
  description = "",
  req = null,
  statusCode = null,
  success = true,
  errorMessage = null,
  metadata = null,
}) {
  try {
    const entry = {
      userId,
      userRole,
      category,
      action,
      target,
      description,
      success,
      errorMessage,
      metadata,
    };

    if (statusCode !== null) entry.statusCode = statusCode;

    if (req) {
      entry.ipAddress =
        req.headers["x-forwarded-for"]?.split(",")[0].trim() ||
        req.socket?.remoteAddress ||
        null;
      entry.userAgent = req.headers["user-agent"] || null;
      entry.endpoint = {
        method: req.method,
        path: req.originalUrl,
      };
    }

    await this.create(entry);
  } catch (err) {
    console.error("[ActivityLog] Failed to write log:", err.message);
  }
};

const ActivityLog = mongoose.model("ActivityLog", activityLogSchema);

export default ActivityLog;
