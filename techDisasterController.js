import Disaster from "../models/disasterEventModel.js";
import ActivityLog from "../models/activityLogModel.js";
import { buildMlPayload, buildBombingMlPayload } from "../utils/techPayLoad.js";

const TECH_ML_URL = process.env.TECH_ML_URL || "http://localhost:9000";
const BOMBING_ML_URL = process.env.BOMBING_ML_URL || "http://localhost:8091";

export const predictAndSaveTech = async (req, res) => {
  try {
    const {
      title,
      description,
      startDate,
      province = "Sindh",
      disasterType,
      ...rest
    } = req.body;

    // Determine which ML service to call based on disaster type
    const isBombing = disasterType === "Bombing/Terrorist";

    let mlData;

    if (isBombing) {
      // Call bombing/drone attack ML service
      const bombingPayload = buildBombingMlPayload(rest);

      const mlResp = await fetch(`${BOMBING_ML_URL}/predict`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(bombingPayload),
      });

      if (!mlResp.ok) {
        const errBody = await mlResp.json().catch(() => ({}));
        return res.status(502).json({
          success: false,
          message: "Bombing ML service error",
          detail: errBody.detail || mlResp.statusText,
        });
      }

      const mlResponse = await mlResp.json();
      // Python returns: { killed_prediction, injured_prediction, killed_confidence_interval, injured_confidence_interval, model_used }

      mlData = {
        predicted_fatalities: Math.round(mlResponse.killed_prediction || 0),
        predicted_injuries: Math.round(mlResponse.injured_prediction || 0),
        raw_scores: {
          fatalities: mlResponse.killed_prediction || 0,
          injuries: mlResponse.injured_prediction || 0,
        },
        model_used: mlResponse.model_used || "Random Forest",
        confidence_intervals: {
          killed: mlResponse.killed_confidence_interval,
          injured: mlResponse.injured_confidence_interval,
        },
      };
    } else {
      // Call road accident ML service (existing)
      const mlResp = await fetch(`${TECH_ML_URL}/predict`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(buildMlPayload(rest)),
      });

      if (!mlResp.ok) {
        const errBody = await mlResp.json().catch(() => ({}));
        return res.status(502).json({
          success: false,
          message: "ML service error",
          detail: errBody.detail || mlResp.statusText,
        });
      }

      mlData = await mlResp.json();
      // Python returns: { predicted_fatalities, predicted_injuries, raw_scores }
    }

    // Build auto-title if none provided
    const autoTitle = isBombing
      ? `${disasterType} - ${rest.city || rest.location || "Unknown"} (${new Date().toLocaleDateString("en-PK")})`
      : title ||
        `${disasterType} - ${rest.Incident_Metadata_Location_Type ?? "Unknown"} (${new Date().toLocaleDateString("en-PK")})`;

    // Build disaster document based on type
    const disasterData = {
      title: autoTitle,
      description: description || `AI-predicted ${disasterType} impact.`,
      disasterType: disasterType,
      disasterCategory: "Technological",
      status: "Ongoing",
      startDate: startDate ? new Date(startDate) : new Date(),
      country: "Pakistan",
      province: isBombing ? rest.province || province : province,
      location: {
        type: "Point",
        coordinates: [0, 0], // tech disasters don't have a geo-point; placeholder
      },
      impact: {
        deaths: mlData.predicted_fatalities,
        injured: mlData.predicted_injuries,
        affected_population:
          mlData.predicted_fatalities + mlData.predicted_injuries,
        houses_damaged: 0,
        houses_demolished: 0,
        crop_area_damaged: 0,
      },
      createdBy: req.user._id,
    };

    // Set tech disaster factors based on type
    if (isBombing) {
      disasterData.techDisasterFactors = {
        attackLocation: rest.location || "Unknown",
        attackCity: rest.city || "Unknown",
        attackProvince: rest.province || province,
        numberOfStrikes: rest.no_of_strikes || 0,
        temperatureCelsius: rest.temperature_c || 0,
        hourOfDay: rest.hour_of_day || 0,
        mlModelUsed: mlData.model_used,
      };
    } else {
      disasterData.techDisasterFactors = {
        context: rest.Incident_Metadata_Context,
        dayOfWeek: rest.Incident_Metadata_Day_of_Week,
        season: rest.Incident_Metadata_Season,
        locationType: rest.Incident_Metadata_Location_Type,
        weatherCondition: rest.Incident_Metadata_Weather_Condition,
        visibilityLevel: rest.Incident_Metadata_Visibility_Level,
        subjectType: rest.Technical_Factors_Subject_Type,
        subjectAgeYears: rest.Technical_Factors_Subject_Age_Years,
        safetyRating: rest.Technical_Factors_Safety_Rating_Score,
        brakeStatus: rest.Technical_Factors_Brake_Status,
        maintenanceStatus: rest.Technical_Factors_Equipment_Maintenance_Status,
        speedAtImpact: rest.Technical_Factors_Speed_at_Impact_KPH,
        totalPassengers: rest.Technical_Factors_Total_Passengers_Onboard,
        collisionType:
          rest.Technical_Factors_Collision_Characteristics_Collision_Type,
        pointOfImpact:
          rest.Technical_Factors_Collision_Characteristics_Point_of_Impact,
        roadSurface:
          rest.Technical_Factors_Collision_Characteristics_Road_Surface_Condition,
        trafficDensity:
          rest.Technical_Factors_Collision_Characteristics_Traffic_Density,
        driverBehavior: rest.Human_Factors_Driver_Worker_Behavior,
        distractionLevel: rest.Human_Factors_Distraction_Level,
        safetyTraining: rest.Human_Factors_Safety_Training_Level,
        shiftHour: rest.Human_Factors_Shift_Hour,
        experienceYears: rest.Human_Factors_Experience_Level_Years,
        firstAidAvailability: rest.Emergency_Response_First_Aid_Availability,
        responseTimeMinutes: rest.Emergency_Response_Response_Time_Minutes,
        distToHospitalKm: rest.Emergency_Response_Distance_to_Hospital_KM,
      };
    }

    const disaster = new Disaster(disasterData);

    // Severity using existing logic
    const { calculateSeverity } = await import("../utils/calculateSeverity.js");
    disaster.severity = calculateSeverity(disaster.impact);

    const saved = await disaster.save();

    // Log activity
    await ActivityLog.log({
      userId: req.user._id,
      userRole: req.user.role,
      category: "disaster",
      action: "PREDICTED",
      target: { model: "DisasterEvent", id: saved._id },
      description: `Tech-disaster AI prediction saved — ${saved.title} (severity: ${saved.severity})`,
      req,
      statusCode: 201,
      success: true,
      metadata: {
        disasterCategory: "Technological",
        disasterType: disasterType,
        mlPredictions: {
          fatalities: mlData.predicted_fatalities,
          injuries: mlData.predicted_injuries,
          rawScores: mlData.raw_scores,
          ...(isBombing && { modelUsed: mlData.model_used }),
        },
      },
    });

    return res.status(201).json({
      success: true,
      predictions: {
        predicted_fatalities: mlData.predicted_fatalities,
        predicted_injuries: mlData.predicted_injuries,
        raw_scores: mlData.raw_scores,
        ...(isBombing && {
          model_used: mlData.model_used,
          confidence_intervals: mlData.confidence_intervals,
        }),
      },
      disaster: saved,
    });
  } catch (error) {
    console.error("[predictAndSaveTech]", error);
    res.status(500).json({ success: false, message: error.message });
  }
};
