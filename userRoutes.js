import express from "express";
import { auth } from "../middleware/authMiddleware.js";
import ActivityLog from "../models/activityLogModel.js";

const router = express.Router();

router.get("/recent-activities", auth, async (req, res) => {
  try {
    const activities = await ActivityLog.find({ userId: req.user._id })
      .sort({ createdAt: -1 })
      .limit(3)
      .select("action description createdAt category")
      .lean();

    const formattedActivities = activities.map((activity) => {
      const timeAgo = getTimeAgo(activity.createdAt);
      return {
        title: activity.description || activity.action,        
        subtitle: timeAgo,
        emphasis: shouldEmphasize(activity.category, activity.action),
        category: activity.category,
        action: activity.action,
      };
    });

    res.json({
      success: true,
      data: formattedActivities,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Failed to fetch recent activities",
    });
  }
});

function getTimeAgo(date) {
  const now = new Date();
  const diff = now - new Date(date);
  const minutes = Math.floor(diff / 60000);
  const hours = Math.floor(minutes / 60);
  const days = Math.floor(hours / 24);

  if (minutes < 1) return "Just now";
  if (minutes < 60) return `${minutes}m ago`;
  if (hours < 24) return `Today, ${formatTime(date)}`;
  if (days === 1) return `Yesterday, ${formatTime(date)}`;
  if (days < 7) return `${days}d ago`;
  return new Date(date).toLocaleDateString("en-US", {
    month: "short",
    day: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  });
}

function formatTime(date) {
  return new Date(date).toLocaleTimeString("en-US", {
    hour: "2-digit",
    minute: "2-digit",
    hour12: true,
  });
}

function shouldEmphasize(category, action) {  
  const importantCategories = ["disaster", "report"];
  const importantActions = ["APPROVED", "BROADCASTED", "ISSUED"];
  return (
    importantCategories.includes(category) || importantActions.includes(action)
  );
}

export default router;