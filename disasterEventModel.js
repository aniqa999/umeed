import mongoose from "mongoose";

const disasterEventSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: true,
      trim: true,
    },
    description: {
      type: String,
      required: true,
    },
    disasterType: {
      type: String,
      required: true,
      enum: [
        "Earthquake",
        "Flood",
        "Wildfire",
        "Cyclone",
        "Heatwave",
        "Drought",
        "Road Accident",
        "Bombing/Terrorist",
        "Other",
      ],
    },
    status: {
      type: String,
      enum: ["Ongoing", "Contained", "Terminated"],
      default: "Ongoing",
    },

    startDate: {
      type: Date,
      required: true,
    },
    endDate: {
      type: Date,
    },

    country: {
      type: String,
      required: true,
    },
    province: {
      type: String,
      required: true,
      enum: ["Punjab", "Sindh", "KPK", "Balochistan", "Gilgit", "FATA", "Islamabad", "Gilgit-Baltistan", "Azad Kashmir"],
    },
    location: {
      type: {
        type: String,
        enum: ["Point"],
        required: true,
      },
      coordinates: {
        type: [Number],
        required: true,
      },
    },
    impact: {
      deaths: { type: Number, default: 0 },
      injured: { type: Number, default: 0 },
      affected_population: { type: Number, default: 0 },
      houses_damaged: { type: Number, default: 0 },
      houses_demolished: { type: Number, default: 0 },
      crop_area_damaged: { type: Number, default: 0 },
    },
    severity: {
      type: String,
      enum: ["Low", "Medium", "High"],
    },
    technicalData: {
      magnitude: {
        type: Number,
        min: 0,
        max: 10,
      },
      river_discharge_cusecs: {
        type: Number,
      },
      temperature_max: {
        type: Number,
      },
    },

    techDisasterFactors: {
      // metadata
      context: { type: String }, // Vehicle, Industrial, etc.
      dayOfWeek: { type: String },
      season: { type: String },
      locationType: { type: String },
      weatherCondition: { type: String },
      visibilityLevel: { type: String },
      // Technical
      subjectType: { type: String },
      subjectAgeYears: { type: Number },
      safetyRating: { type: Number },
      brakeStatus: { type: String },
      maintenanceStatus: { type: String },
      speedAtImpact: { type: Number },
      totalPassengers: { type: Number },
      // Collision
      collisionType: { type: String },
      pointOfImpact: { type: String },
      roadSurface: { type: String },
      trafficDensity: { type: String },
      // factors
      driverBehavior: { type: String },
      distractionLevel: { type: String },
      safetyTraining: { type: String },
      shiftHour: { type: Number },
      experienceYears: { type: Number },
      // response
      firstAidAvailability: { type: String },
      responseTimeMinutes: { type: Number },
      distToHospitalKm: { type: Number },

      // Bombing/Attack specific fields
      attackLocation: { type: String },
      attackCity: { type: String },
      attackProvince: { type: String },
      numberOfStrikes: { type: Number },
      temperatureCelsius: { type: Number },
      hourOfDay: { type: Number },
      mlModelUsed: { type: String },
    },

    disasterCategory: {
      type: String,
      enum: ["Natural", "Technological"],
      default: "Natural",
    },

    createdBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
  },
  { timestamps: true },
);

disasterEventSchema.index({ startDate: 1 });
disasterEventSchema.index({ province: 1 });
disasterEventSchema.index({ disasterType: 1 });
disasterEventSchema.index({ status: 1 });

const disasterModel = mongoose.model("DisasterEvent", disasterEventSchema);

export default disasterModel;
