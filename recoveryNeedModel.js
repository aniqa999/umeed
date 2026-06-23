import mongoose from "mongoose";

const resourceSchema = new mongoose.Schema(
  {
    createdBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },

    disasterId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "DisasterEvent",
      required: true,
    },
    region: {
      type: String,
      required: true,
      trim: true,
    },
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
  { timestamps: true },
);

resourceSchema.index({ disasterId: 1 });
resourceSchema.index({ region: 1 });

const ResourceModel = mongoose.model("Resources", resourceSchema);

export default ResourceModel;
