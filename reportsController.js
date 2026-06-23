import Report from "../models/reportModel.js";
import Disaster from "../models/disasterEventModel.js";
import Resource from "../models/recoveryNeedModel.js";
import ActivityLog from "../models/activityLogModel.js";
import { calculateResources } from "../services/calculationServices.js";
import { getClimateFactor } from "../utils/climateAdjustments.js";
import { buildResourceSnapshot } from "../utils/buildResourceSnapshot.js";

const generateReport = async (req, res) => {
  try {
    const { disasterId, duration_days = 7, title, notes } = req.body;

    if (!disasterId) {
      return res.status(400).json({
        success: false,
        message: "disasterId is required.",
      });
    }

    const disaster = await Disaster.findById(disasterId);
    if (!disaster) {
      return res.status(404).json({
        success: false,
        message: "Disaster not found.",
      });
    }

    const resources = calculateResources({
      affected_population: disaster.impact.affected_population,
      injured: disaster.impact.injured,
      houses_damaged: disaster.impact.houses_damaged,
      houses_demolished: disaster.impact.houses_demolished,
      duration_days: Number(duration_days),
      province: disaster.province,
    });

    const climate = getClimateFactor(disaster.province);

    const disasterSnapshot = {
      title: disaster.title,
      disasterType: disaster.disasterType,
      province: disaster.province,
      country: disaster.country,
      status: disaster.status,
      startDate: disaster.startDate,
      endDate: disaster.endDate || null,
      severity: disaster.severity,
      impact: {
        deaths: disaster.impact.deaths,
        injured: disaster.impact.injured,
        affected_population: disaster.impact.affected_population,
        houses_damaged: disaster.impact.houses_damaged,
        houses_demolished: disaster.impact.houses_demolished,
        crop_area_damaged: disaster.impact.crop_area_damaged,
      },
      technicalData: {
        magnitude: disaster.technicalData?.magnitude || null,
        river_discharge_cusecs:
          disaster.technicalData?.river_discharge_cusecs || null,
        temperature_max: disaster.technicalData?.temperature_max || null,
      },
    };

    const resourceSnapshot = buildResourceSnapshot(resources);

    const reportTitle =
      title?.trim() ||
      `${disaster.disasterType} Impact Report — ${disaster.province} (${new Date().toLocaleDateString("en-PK")})`;

    const resourceDoc = await Resource.findOneAndUpdate(
      { disasterId: disaster._id },
      {
        region: disaster.province,
        affected_population: resourceSnapshot.affected_population,
        households: resourceSnapshot.households,
        water_liters: resourceSnapshot.water_liters,
        food_kg: resourceSnapshot.food_kg,
        food_tons: resourceSnapshot.food_tons,
        shelter: resourceSnapshot.shelter,
        nfi: resourceSnapshot.nfi,
        health: resourceSnapshot.health,
        sanitation: resourceSnapshot.sanitation,
        logistics: resourceSnapshot.logistics,
      },
      { returnDocument: "after", upsert: true },
    );

    const report = await Report.create({
      disasterId: disaster._id,
      resourceId: resourceDoc._id,
      generatedBy: req.user._id,
      title: reportTitle,
      notes: notes?.trim() || "",
      status: "generated",
      disasterSnapshot,
      durationDays: Number(duration_days),
      resourceSnapshot,
      climateAdjustments: climate,
    });

    await ActivityLog.log({
      userId: req.user._id,
      userRole: req.user.role,
      category: "report",
      action: "GENERATED",
      target: { model: "Report", id: report._id },
      description: `Report generated for ${disaster.disasterType} disaster in ${disaster.province}`,
      req,
      statusCode: 201,
      success: true,
      metadata: {
        reportNumber: report.reportNumber,
        disasterId: disaster._id,
        durationDays: duration_days,
      },
    });

    res.status(201).json({
      success: true,
      message: "Report generated successfully.",
      data: report,
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

const getAllReports = async (req, res) => {
  try {
    const { status, disasterId, page = 1, limit = 20 } = req.query;

    const query = {};

    if (req.user.role !== "admin") {
      query.generatedBy = req.user._id;
    }

    if (status) query.status = status;
    if (disasterId) query.disasterId = disasterId;

    if (!status && req.user.role !== "admin") {
      query.status = { $ne: "archived" };
    }

    const skip = (Number(page) - 1) * Number(limit);
    const total = await Report.countDocuments(query);

    const reports = await Report.find(query)
      .populate("generatedBy", "fullName email role organization")
      .populate("disasterId", "title disasterType province status")
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
      .populate("generatedBy", "fullName email role organization")
      .populate("disasterId", "title disasterType province status startDate");

    if (!report) {
      return res
        .status(404)
        .json({ success: false, message: "Report not found." });
    }

    if (
      req.user.role !== "admin" &&
      report.generatedBy._id.toString() !== req.user._id.toString()
    ) {
      return res.status(403).json({
        success: false,
        message: "You do not have permission to view this report.",
      });
    }

    res.json({ success: true, data: report });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

const getReportsByDisaster = async (req, res) => {
  try {
    const query = { disasterId: req.params.disasterId };

    if (req.user.role !== "admin") {
      query.generatedBy = req.user._id;
    }

    const reports = await Report.find(query)
      .populate("generatedBy", "fullName email role")
      .sort({ createdAt: -1 });

    res.json({
      success: true,
      count: reports.length,
      data: reports,
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

const downloadReport = async (req, res) => {
  try {
    const report = await Report.findById(req.params.id)
      .populate("generatedBy", "fullName email role")
      .populate("disasterId", "title disasterType province");

    if (!report) {
      return res
        .status(404)
        .json({ success: false, message: "Report not found." });
    }

    if (
      req.user.role !== "admin" &&
      report.generatedBy._id.toString() !== req.user._id.toString()
    ) {
      return res.status(403).json({
        success: false,
        message: "You do not have permission to download this report.",
      });
    }

    if (report.status === "archived") {
      return res.status(410).json({
        success: false,
        message:
          "This report has been archived and is no longer available for download.",
      });
    }

    await report.recordDownload();

    await ActivityLog.log({
      userId: req.user._id,
      userRole: req.user.role,
      category: "report",
      action: "DOWNLOADED",
      target: { model: "Report", id: report._id },
      description: `Report ${report.reportNumber} downloaded`,
      req,
      statusCode: 200,
      success: true,
      metadata: {
        reportNumber: report.reportNumber,
        downloadCount: report.downloadCount,
      },
    });

    // PDF Generation is still required
    res.json({
      success: true,
      message: "Report data ready. Integrate PDF generation as needed.",
      reportNumber: report.reportNumber,
      data: report,
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

const updateReportNotes = async (req, res) => {
  try {
    const { notes } = req.body;

    if (notes === undefined) {
      return res
        .status(400)
        .json({ success: false, message: "notes field is required." });
    }

    const report = await Report.findById(req.params.id);

    if (!report) {
      return res
        .status(404)
        .json({ success: false, message: "Report not found." });
    }

    if (
      req.user.role !== "admin" &&
      report.generatedBy.toString() !== req.user._id.toString()
    ) {
      return res.status(403).json({
        success: false,
        message: "You do not have permission to edit this report.",
      });
    }

    report.notes = notes.trim();
    await report.save();

    res.json({ success: true, message: "Notes updated.", data: report });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

const archiveReport = async (req, res) => {
  try {
    const report = await Report.findById(req.params.id);

    if (!report) {
      return res
        .status(404)
        .json({ success: false, message: "Report not found." });
    }

    if (report.status === "archived") {
      return res
        .status(400)
        .json({ success: false, message: "Report is already archived." });
    }

    report.status = "archived";
    await report.save();

    await ActivityLog.log({
      userId: req.user._id,
      userRole: req.user.role,
      category: "report",
      action: "DELETED",
      target: { model: "Report", id: report._id },
      description: `Report ${report.reportNumber} archived by admin`,
      req,
      statusCode: 200,
      success: true,
    });

    res.json({
      success: true,
      message: `Report ${report.reportNumber} has been archived.`,
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

const deleteReport = async (req, res) => {
  try {
    const report = await Report.findByIdAndDelete(req.params.id);

    if (!report) {
      return res
        .status(404)
        .json({ success: false, message: "Report not found." });
    }

    await ActivityLog.log({
      userId: req.user._id,
      userRole: req.user.role,
      category: "report",
      action: "DELETED",
      target: { model: "Report", id: report._id },
      description: `Report ${report.reportNumber} permanently deleted by admin`,
      req,
      statusCode: 200,
      success: true,
    });

    res.json({
      success: true,
      message: `Report ${report.reportNumber} has been permanently deleted.`,
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export {
  generateReport,
  getAllReports,
  getReportById,
  getReportsByDisaster,
  downloadReport,
  updateReportNotes,
  archiveReport,
  deleteReport,
};
