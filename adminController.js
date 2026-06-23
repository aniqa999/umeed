import User from "../models/userModel.js";
import ActivityLog from "../models/activityLogModel.js";
import Disaster from "../models/disasterEventModel.js";
import Report from "../models/reportModel.js";

const getAllUsers = async (req, res) => {
  try {
    const { role, status, province, search } = req.query;

    const query = {};

    if (role) query.role = role;
    if (status) query.status = status;
    if (province) query.province = province;

    if (search) {
      query.$or = [
        { fullName: { $regex: search, $options: "i" } },
        { email: { $regex: search, $options: "i" } },
        { organization: { $regex: search, $options: "i" } },
      ];
    }

    const users = await User.find(query)
      .populate("reviewedBy", "fullName email")
      .sort({ createdAt: -1 });

    res.json({
      success: true,
      count: users.length,
      data: users.map((u) => u.toPublicJSON()),
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

const getPendingUsers = async (req, res) => {
  try {
    const users = await User.find({ status: "pending" }).sort({ createdAt: 1 });

    res.json({
      success: true,
      count: users.length,
      data: users.map((u) => u.toPublicJSON()),
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

const getUserById = async (req, res) => {
  try {
    const user = await User.findById(req.params.id).populate(
      "reviewedBy",
      "fullName email",
    );

    if (!user) {
      return res
        .status(404)
        .json({ success: false, message: "User not found." });
    }

    res.json({ success: true, data: user.toPublicJSON() });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

const approveUser = async (req, res) => {
  try {
    const target = await User.findById(req.params.id);

    if (!target) {
      return res
        .status(404)
        .json({ success: false, message: "User not found." });
    }

    if (target.role === "admin") {
      return res.status(400).json({
        success: false,
        message: "Admin accounts cannot be managed through this endpoint.",
      });
    }

    if (target.status === "approved") {
      return res.status(400).json({
        success: false,
        message: "This account is already approved.",
      });
    }

    target.status = "approved";
    target.reviewedBy = req.user._id;
    target.reviewedAt = new Date();
    target.reviewNote = req.body.note || null;
    await target.save({ validateBeforeSave: false });

    await ActivityLog.log({
      userId: req.user._id,
      userRole: req.user.role,
      category: "user",
      action: "APPROVED",
      target: { model: "User", id: target._id },
      description: `Admin approved ${target.role} account: ${target.email}`,
      req,
      statusCode: 200,
      success: true,
      metadata: { approvedUser: target.email, approvedRole: target.role },
    });

    res.json({
      success: true,
      message: `${target.fullName}'s account has been approved.`,
      user: target.toPublicJSON(),
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

const rejectUser = async (req, res) => {
  try {
    const { note } = req.body;

    if (!note?.trim()) {
      return res.status(400).json({
        success: false,
        message: "A rejection reason (note) is required.",
      });
    }

    const target = await User.findById(req.params.id);

    if (!target) {
      return res
        .status(404)
        .json({ success: false, message: "User not found." });
    }

    if (target.role === "admin") {
      return res.status(400).json({
        success: false,
        message: "Admin accounts cannot be managed through this endpoint.",
      });
    }

    if (target.status === "rejected") {
      return res.status(400).json({
        success: false,
        message: "This account is already rejected.",
      });
    }

    target.status = "rejected";
    target.reviewedBy = req.user._id;
    target.reviewedAt = new Date();
    target.reviewNote = note.trim();
    await target.save({ validateBeforeSave: false });

    await ActivityLog.log({
      userId: req.user._id,
      userRole: req.user.role,
      category: "user",
      action: "REJECTED",
      target: { model: "User", id: target._id },
      description: `Admin rejected ${target.role} account: ${target.email}. Reason: ${note}`,
      req,
      statusCode: 200,
      success: true,
      metadata: { rejectedUser: target.email, reason: note },
    });

    res.json({
      success: true,
      message: `${target.fullName}'s account has been rejected.`,
      user: target.toPublicJSON(),
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
const suspendUser = async (req, res) => {
  try {
    const target = await User.findById(req.params.id);

    if (!target) {
      return res
        .status(404)
        .json({ success: false, message: "User not found." });
    }

    if (target.role === "admin") {
      return res.status(400).json({
        success: false,
        message: "Admin accounts cannot be suspended through this endpoint.",
      });
    }

    if (target.status === "suspended") {
      return res.status(400).json({
        success: false,
        message: "This account is already suspended.",
      });
    }

    target.status = "suspended";
    target.reviewedBy = req.user._id;
    target.reviewedAt = new Date();
    target.reviewNote = req.body.note?.trim() || null;
    await target.save({ validateBeforeSave: false });

    await ActivityLog.log({
      userId: req.user._id,
      userRole: req.user.role,
      category: "user",
      action: "SUSPENDED",
      target: { model: "User", id: target._id },
      description: `Admin suspended ${target.role} account: ${target.email}`,
      req,
      statusCode: 200,
      success: true,
      metadata: {
        suspendedUser: target.email,
        reason: target.reviewNote,
      },
    });

    res.json({
      success: true,
      message: `${target.fullName}'s account has been suspended.`,
      user: target.toPublicJSON(),
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

const reinstateUser = async (req, res) => {
  try {
    const target = await User.findById(req.params.id);

    if (!target) {
      return res
        .status(404)
        .json({ success: false, message: "User not found." });
    }

    if (!["suspended", "rejected"].includes(target.status)) {
      return res.status(400).json({
        success: false,
        message: "Only suspended or rejected accounts can be reinstated.",
      });
    }

    target.status = "approved";
    target.reviewedBy = req.user._id;
    target.reviewedAt = new Date();
    target.reviewNote = req.body.note?.trim() || null;
    await target.save({ validateBeforeSave: false });

    await ActivityLog.log({
      userId: req.user._id,
      userRole: req.user.role,
      category: "user",
      action: "APPROVED",
      target: { model: "User", id: target._id },
      description: `Admin reinstated ${target.role} account: ${target.email}`,
      req,
      statusCode: 200,
      success: true,
    });

    res.json({
      success: true,
      message: `${target.fullName}'s account has been reinstated.`,
      user: target.toPublicJSON(),
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

const getActivityLogs = async (req, res) => {
  try {
    const {
      userId,
      category,
      action,
      success,
      from,
      to,
      page = 1,
      limit = 50,
    } = req.query;

    const query = {};

    if (userId) query.userId = userId;
    if (category) query.category = category;
    if (action) query.action = action.toUpperCase();

    if (success !== undefined) {
      query.success = success === "true";
    }

    if (from || to) {
      query.createdAt = {};
      if (from) query.createdAt.$gte = new Date(from);
      if (to) query.createdAt.$lte = new Date(to);
    }

    const skip = (Number(page) - 1) * Number(limit);
    const total = await ActivityLog.countDocuments(query);

    const logs = await ActivityLog.find(query)
      .populate("userId", "fullName email role")
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(Number(limit));

    res.json({
      success: true,
      total,
      page: Number(page),
      totalPages: Math.ceil(total / Number(limit)),
      data: logs,
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

const getUserActivityLogs = async (req, res) => {
  try {
    const { userId } = req.params;
    const { page = 1, limit = 30 } = req.query;

    const skip = (Number(page) - 1) * Number(limit);
    const total = await ActivityLog.countDocuments({ userId });

    const logs = await ActivityLog.find({ userId })
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(Number(limit));

    res.json({
      success: true,
      total,
      page: Number(page),
      totalPages: Math.ceil(total / Number(limit)),
      data: logs,
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

const getPlatformStats = async (req, res) => {
  try {
    const [
      totalUsers,
      pendingUsers,
      approvedUsers,
      rejectedUsers,
      suspendedUsers,
      totalDisasters,
      totalReports,
    ] = await Promise.all([
      User.countDocuments({ role: { $ne: "admin" } }),
      User.countDocuments({ status: "pending" }),
      User.countDocuments({ status: "approved", role: { $ne: "admin" } }),
      User.countDocuments({ status: "rejected" }),
      User.countDocuments({ status: "suspended" }),
      Disaster.countDocuments(),
      Report.countDocuments(),
    ]);

    const [ngoCount, govCount] = await Promise.all([
      User.countDocuments({ role: "ngo" }),
      User.countDocuments({ role: "government" }),
    ]);

    const sevenDaysAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);
    const recentLogs = await ActivityLog.countDocuments({
      createdAt: { $gte: sevenDaysAgo },
    });

    res.json({
      success: true,
      stats: {
        users: {
          total: totalUsers,
          pending: pendingUsers,
          approved: approvedUsers,
          rejected: rejectedUsers,
          suspended: suspendedUsers,
          byRole: { ngo: ngoCount, government: govCount },
        },
        disasters: { total: totalDisasters },
        reports: { total: totalReports },
        activity: { last7Days: recentLogs },
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

const getAllDisasters = async (req, res) => {
  try {
    const {
      status,
      disasterType,
      province,
      disasterCategory,
      severity,
      search,
      from,
      to,
      page = 1,
      limit = 20,
    } = req.query;

    const query = {};

    if (status) query.status = status;
    if (disasterType) query.disasterType = disasterType;
    if (province) query.province = province;
    if (disasterCategory) query.disasterCategory = disasterCategory;
    if (severity) query.severity = severity;

    if (search) {
      query.$or = [
        { title: { $regex: search, $options: "i" } },
        { description: { $regex: search, $options: "i" } },
      ];
    }

    if (from || to) {
      query.startDate = {};
      if (from) query.startDate.$gte = new Date(from);
      if (to) query.startDate.$lte = new Date(to);
    }

    const skip = (Number(page) - 1) * Number(limit);
    const total = await Disaster.countDocuments(query);

    const disasters = await Disaster.find(query)
      .populate("createdBy", "fullName email role")
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(Number(limit));

    res.json({
      success: true,
      total,
      page: Number(page),
      totalPages: Math.ceil(total / Number(limit)),
      data: disasters,
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

const getDisasterById = async (req, res) => {
  try {
    const disaster = await Disaster.findById(req.params.id).populate(
      "createdBy",
      "fullName email role",
    );

    if (!disaster) {
      return res
        .status(404)
        .json({ success: false, message: "Disaster not found." });
    }

    res.json({ success: true, data: disaster });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

const getAllResources = async (req, res) => {
  try {
    const { region, disasterId, page = 1, limit = 20 } = req.query;

    const query = {};

    if (region) query.region = { $regex: region, $options: "i" };
    if (disasterId) query.disasterId = disasterId;

    const skip = (Number(page) - 1) * Number(limit);
    const total = await ResourceModel.countDocuments(query);

    const resources = await ResourceModel.find(query)
      .populate("createdBy", "fullName email role")
      .populate("disasterId", "title disasterType province")
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(Number(limit));

    res.json({
      success: true,
      total,
      page: Number(page),
      totalPages: Math.ceil(total / Number(limit)),
      data: resources,
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

const getResourceById = async (req, res) => {
  try {
    const resource = await ResourceModel.findById(req.params.id)
      .populate("createdBy", "fullName email role")
      .populate("disasterId", "title disasterType province status");

    if (!resource) {
      return res
        .status(404)
        .json({ success: false, message: "Resource not found." });
    }

    res.json({ success: true, data: resource });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

const getAllReports = async (req, res) => {
  try {
    const {
      status,
      disasterId,
      generatedBy,
      from,
      to,
      search,
      page = 1,
      limit = 20,
    } = req.query;

    const query = {};

    if (status) query.status = status;
    if (disasterId) query.disasterId = disasterId;
    if (generatedBy) query.generatedBy = generatedBy;

    if (search) {
      query.$or = [
        { title: { $regex: search, $options: "i" } },
        { reportNumber: { $regex: search, $options: "i" } },
        { notes: { $regex: search, $options: "i" } },
      ];
    }

    if (from || to) {
      query.createdAt = {};
      if (from) query.createdAt.$gte = new Date(from);
      if (to) query.createdAt.$lte = new Date(to);
    }

    const skip = (Number(page) - 1) * Number(limit);
    const total = await Report.countDocuments(query);

    const reports = await Report.find(query)
      .populate("disasterId", "title disasterType province status")
      .populate("generatedBy", "fullName email role")
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(Number(limit));

    res.json({
      success: true,
      total,
      page: Number(page),
      totalPages: Math.ceil(total / Number(limit)),
      data: reports,
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

const getReportById = async (req, res) => {
  try {
    const report = await Report.findById(req.params.id)
      .populate("disasterId", "title disasterType province status")
      .populate("generatedBy", "fullName email role")
      .populate("resourceId");

    if (!report) {
      return res
        .status(404)
        .json({ success: false, message: "Report not found." });
    }

    res.json({ success: true, data: report });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export {
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
};
