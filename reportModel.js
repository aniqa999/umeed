import mongoose from "mongoose";

const impactSnapshotSchema = new mongoose.Schema(
  {
    deaths: { type: Number, default: 0 },
    injured: { type: Number, default: 0 },
    affected_population: { type: Number, default: 0 },
    houses_damaged: { type: Number, default: 0 },
    houses_demolished: { type: Number, default: 0 },
    crop_area_damaged: { type: Number, default: 0 },
  },
  { _id: false },
);

const resourceSnapshotSchema = new mongoose.Schema(
  {
    affected_population: { type: Number, default: 0 },
    households: { type: Number, default: 0 },

    water_liters: { type: Number, default: 0 },

    food_kg: { type: Number, default: 0 },
    food_tons: { type: Number, default: 0 },

    shelter: {
      tents: { type: Number, default: 0 },
      tarpaulins: { type: Number, default: 0 },
    },

    nfi: {
      kitchen_sets: { type: Number, default: 0 },
      jerry_cans: { type: Number, default: 0 },
      blankets: { type: Number, default: 0 },
      plastic_mats: { type: Number, default: 0 },
    },

    health: {
      iehk_kits: { type: Number, default: 0 },
    },

    sanitation: {
      latrines: { type: Number, default: 0 },
    },

    logistics: {
      trucks_required: { type: Number, default: 0 },
      storage_space_sqft: { type: Number, default: 0 },
    },
  },
  { _id: false },
);

const reportSchema = new mongoose.Schema(
  {
    disasterId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "DisasterEvent",
      required: true,
    },

    resourceId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Resources",
      default: null,
    },

    generatedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },

    reportNumber: {
      type: String,
    },

    title: {
      type: String,
      trim: true,
      required: true,
    },

    notes: {
      type: String,
      trim: true,
      default: "",
    },

    status: {
      type: String,
      enum: ["draft", "generated", "archived"],
      default: "draft",
    },

    disasterSnapshot: {
      title: { type: String },
      disasterType: { type: String },
      province: { type: String },
      country: { type: String },
      status: { type: String },
      startDate: { type: Date },
      endDate: { type: Date, default: null },
      severity: { type: String, enum: ["Low", "Medium", "High"] },
      impact: { type: impactSnapshotSchema },
      technicalData: {
        magnitude: { type: Number, default: null },
        river_discharge_cusecs: { type: Number, default: null },
        temperature_max: { type: Number, default: null },
      },
    },

    durationDays: {
      type: Number,
      default: 7,
    },

    resourceSnapshot: {
      type: resourceSnapshotSchema,
    },

    climateAdjustments: {
      water_multiplier: { type: Number, default: 1 },
      blanket_multiplier: { type: Number, default: 1 },
      tarp_multiplier: { type: Number, default: 1 },
    },

    pdfUrl: {
      type: String,
      default: null,
    },

    pdfGeneratedAt: {
      type: Date,
      default: null,
    },

    downloadCount: {
      type: Number,
      default: 0,
    },
  },
  {
    timestamps: true,
  },
);

reportSchema.index({ disasterId: 1 });
reportSchema.index({ generatedBy: 1 });
reportSchema.index({ status: 1 });
reportSchema.index({ createdAt: -1 });
reportSchema.index({ reportNumber: 1 }, { unique: true, sparse: true });

reportSchema.pre("save", async function () {
  if (this.reportNumber) return;

  const today = new Date();
  const datePart = today.toISOString().slice(0, 10).replace(/-/g, "");

  const startOfDay = new Date(today.setHours(0, 0, 0, 0));
  const endOfDay = new Date(today.setHours(23, 59, 59, 999));

  const todayCount = await this.constructor.countDocuments({
    createdAt: { $gte: startOfDay, $lte: endOfDay },
  });

  const seq = String(todayCount + 1).padStart(5, "0");
  this.reportNumber = `RPT-${datePart}-${seq}`;
});

reportSchema.methods.recordDownload = async function () {
  this.downloadCount += 1;
  return this.save();
};

const Report = mongoose.model("Report", reportSchema);

export default Report;
