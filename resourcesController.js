import { calculateResources } from "../services/calculationServices.js";
import { getClimateFactor } from "../utils/climateAdjustments.js";
import Disaster from "../models/disasterEventModel.js";
import Resource from "../models/recoveryNeedModel.js";
import ActivityLog from "../models/activityLogModel.js";

const mapCalcToSchema = (calc, disaster, userId) => ({
  createdBy: userId,
  disasterId: disaster._id,
  region: disaster.province,
  affected_population: calc.executive_summary.total_population,
  households: calc.executive_summary.total_households,
  water_liters: calc.detailed_resources.water_liters,
  food_kg: calc.detailed_resources.food_kg,
  food_tons: calc.logistics.total_food_tons,
  shelter: calc.detailed_resources.shelter,
  nfi: calc.detailed_resources.nfi_kits,
  health: calc.detailed_resources.health,
  sanitation: calc.detailed_resources.sanitation,
  logistics: {
    trucks_required: calc.logistics.trucks_required,
    storage_space_sqft: calc.logistics.storage_space_sqft,
  },
});

const calculateAndStore = async (req, res) => {
  try {
  
    const {
      disasterId,
      affected_population,
      injured,
      houses_damaged = 0,
      houses_demolished = 0,
      duration_days,
      province = "Punjab",
    } = req.body;

    if (!disasterId) {
      return res.status(400).json({
        success: false,
        error: "disasterId is required to create resources for a disaster.",
      });
    }

    if (!affected_population || !injured || !duration_days) {
      return res.status(400).json({
        success: false,
        error: "affected_population, injured, and duration_days are required.",
      });
    }

    const disaster = await Disaster.findById(disasterId);
    if (!disaster) {
      return res.status(404).json({
        success: false,
        error: "Disaster not found.",
      });
    }

    const existingResource = await Resource.findOne({ disasterId });
    if (existingResource) {
      return res.status(409).json({
        success: false,
        error:
          "Resources already exist for this disaster. Use recalculate endpoint to update.",
        existingResource,
      });
    }

    const calc = calculateResources({
      affected_population: Number(affected_population),
      injured: Number(injured),
      houses_damaged: Number(houses_damaged),
      houses_demolished: Number(houses_demolished),
      duration_days: Number(duration_days),
      province,
    });

    const climate = getClimateFactor(province);

    const savedResource = await Resource.create(
      mapCalcToSchema(calc, disaster, req.user._id),
    );

    await ActivityLog.log({
      userId: req.user._id,
      userRole: req.user.role,
      category: "resource",
      action: "CREATED",
      target: { model: "Resources", id: savedResource._id },
      description: `NGO ${req.user.name || req.user._id} created resources for disaster in ${province} (${duration_days} days)`,
      req,
      statusCode: 201,
      success: true,
      metadata: {
        disasterId,
        duration_days: Number(duration_days),
        province,
        ngoId: req.user._id,
      },
    });

    res.status(201).json({
      success: true,
      message: "Resources successfully created for disaster.",
      resource: savedResource,
      calculation: {
        ...calc,
        climate_adjustments: climate,
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

const getAllResources = async (req, res) => {
  try {
    const { province, page = 1, limit = 20 } = req.query;

    const query = {};
    if (province) query.region = new RegExp(`^${province}$`, "i");

    const skip = (Number(page) - 1) * Number(limit);
    const total = await Resource.countDocuments(query);

    const resources = await Resource.find(query)
      .populate(
        "disasterId",
        "title disasterType province status severity startDate",
      )
      .sort({ updatedAt: -1 })
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
    res.status(500).json({ success: false, error: error.message });
  }
};

const getResourcesByDisasterId = async (req, res) => {
  try {
    const { disasterId } = req.params;

    const disaster = await Disaster.findById(disasterId);
    if (!disaster) {
      return res
        .status(404)
        .json({ success: false, message: "Disaster not found." });
    }

    const resources = await Resource.findOne({ disasterId });

    if (!resources) {
      return res.status(404).json({
        success: false,
        message:
          "No resource record found for this disaster. Trigger a calculation first.",
      });
    }

    res.json({
      success: true,
      disaster: {
        _id: disaster._id,
        title: disaster.title,
        disasterType: disaster.disasterType,
        province: disaster.province,
        severity: disaster.severity,
        status: disaster.status,
        startDate: disaster.startDate,
        impact: disaster.impact,
      },
      resources,
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

const getAllDisastersWithResources = async (req, res) => {
  try {
    const { province, disasterType, status } = req.query;

    const query = {};
    if (province) query.province = new RegExp(`^${province}$`, "i");
    if (disasterType) query.disasterType = disasterType;
    if (status) query.status = status;

    const disasters = await Disaster.find(query).sort({ createdAt: -1 }).lean();

    const disasterIds = disasters.map((d) => d._id);
    const resourceDocs = await Resource.find({
      disasterId: { $in: disasterIds },
    }).lean();

    const resourceMap = {};
    resourceDocs.forEach((r) => {
      resourceMap[r.disasterId.toString()] = r;
    });

    const result = disasters.map((d) => ({
      ...d,
      resources: resourceMap[d._id.toString()] || null,
    }));

    res.json({
      success: true,
      count: result.length,
      data: result,
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

const recalculateResources = async (req, res) => {
  try {
    // if (req.user.role !== "ngo") {
    //   return res.status(403).json({
    //     success: false,
    //     error: "Only NGOs can recalculate resource requirements.",
    //   });
    // }

    const { disasterId } = req.params;
    const { duration_days = 7 } = req.body;

    const disaster = await Disaster.findById(disasterId);
    if (!disaster) {
      return res
        .status(404)
        .json({ success: false, message: "Disaster not found." });
    }

    const existingResource = await Resource.findOne({ disasterId });
    if (!existingResource) {
      return res.status(404).json({
        success: false,
        message:
          "No resource record found for this disaster. Use calculate endpoint to create one.",
      });
    }

    const calc = calculateResources({
      affected_population: disaster.impact.affected_population,
      injured: disaster.impact.injured,
      houses_damaged: disaster.impact.houses_damaged,
      houses_demolished: disaster.impact.houses_demolished,
      duration_days: Number(duration_days),
      province: disaster.province,
    });

    const updated = await Resource.findOneAndUpdate(
      { disasterId: disaster._id },
      mapCalcToSchema(calc, disaster, req.user._id),
      { returnDocument: "after", runValidators: true },
    );

    await ActivityLog.log({
      userId: req.user._id,
      userRole: req.user.role,
      category: "resource",
      action: "RECALCULATED",
      target: { model: "Resources", id: updated._id },
      description: `NGO ${req.user.name || req.user._id} recalculated resources for ${disaster.disasterType} in ${disaster.province} (${duration_days} days)`,
      req,
      statusCode: 200,
      success: true,
      metadata: {
        disasterId: disaster._id,
        duration_days: Number(duration_days),
        ngoId: req.user._id,
      },
    });

    res.json({
      success: true,
      message: `Resources recalculated for ${Number(duration_days)} days.`,
      disaster: {
        _id: disaster._id,
        title: disaster.title,
        disasterType: disaster.disasterType,
        province: disaster.province,
        severity: disaster.severity,
      },
      resources: updated,
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

const deleteResourceRecord = async (req, res) => {
  try {
    const { disasterId } = req.params;

    const disaster = await Disaster.findById(disasterId);
    if (!disaster) {
      return res
        .status(404)
        .json({ success: false, message: "Disaster not found." });
    }

    const deleted = await Resource.findOneAndDelete({ disasterId });

    if (!deleted) {
      return res.status(404).json({
        success: false,
        message: "No resource record found for this disaster.",
      });
    }

    await ActivityLog.log({
      userId: req.user._id,
      userRole: req.user.role,
      category: "resource",
      action: "DELETED",
      target: { model: "Resources", id: deleted._id },
      description: `Resource record deleted for ${disaster.disasterType} in ${disaster.province}`,
      req,
      statusCode: 200,
      success: true,
      metadata: { disasterId },
    });

    res.json({
      success: true,
      message:
        "Resource record deleted. The disaster event itself is unchanged.",
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

const getDisastersWithoutResources = async (req, res) => {
  try {
    // if (req.user.role !== "ngo") {
    //   return res.status(403).json({
    //     success: false,
    //     error:
    //       "Access denied. Only NGOs can view disasters pending resource allocation.",
    //   });
    // }

    const { province, disasterType, status } = req.query;

    const query = {};
    if (province) query.province = new RegExp(`^${province}$`, "i");
    if (disasterType) query.disasterType = disasterType;
    if (status) query.status = status;

    const disasters = await Disaster.find(query).sort({ createdAt: -1 }).lean();

    const disastersWithResources = await Resource.distinct("disasterId");
    const disasterIdsWithResources = disastersWithResources.map((id) =>
      id.toString(),
    );

    const disastersWithoutResources = disasters.filter(
      (disaster) => !disasterIdsWithResources.includes(disaster._id.toString()),
    );

    res.json({
      success: true,
      count: disastersWithoutResources.length,
      data: disastersWithoutResources,
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

const getMyResources = async (req, res) => {
  try {
    const resources = await Resource.countDocuments({
      createdBy: req.user._id,
    });

    if (!resources) {
      return res.status(404).json({
        success: false,
        message:
          "No resource record found for this disaster. Trigger a calculation first.",
      });
    }

    res.json({
      success: true,
      resources,
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

export {
  calculateAndStore,
  getAllResources,
  getResourcesByDisasterId,
  getAllDisastersWithResources,
  recalculateResources,
  deleteResourceRecord,
  getDisastersWithoutResources,
  getMyResources,
};
