from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import joblib
import pandas as pd
import numpy as np
import os
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="Umeed Disaster Impact Prediction API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize as None to check status later
models = {}
encoders = None
feature_cols = None

TARGETS = [
    'deaths', 'injured', 'affected_population', 
    'houses_damaged', 'houses_demolished', 'crop_area_damaged'
]

def load_artifacts():
    global models, encoders, feature_cols
    try:
        # Verify files exist before loading to give better error messages
        required_files = [f"model_{t}.pkl" for t in TARGETS] + ["label_encoders.pkl", "feature_cols.pkl"]
        for f in required_files:
            if not os.path.exists(f):
                print(f"CRITICAL ERROR: Missing file {f}")
        
        models = {t: joblib.load(f"model_{t}.pkl") for t in TARGETS}
        encoders = joblib.load("label_encoders.pkl")
        feature_cols = joblib.load("feature_cols.pkl")
        print("Successfully loaded all ML artifacts.")
    except Exception as e:
        print(f"Failed to load artifacts: {e}")

# Load artifacts on startup
load_artifacts()

class DisasterEvent(BaseModel):
    province: str
    latitude: float
    longitude: float
    elevation: float
    slope: float
    year: int
    month: int
    season: str
    disaster_type: str
    disaster_subtype: str
    temperature_avg: float
    temperature_max: float
    humidity: float
    heat_index: float
    rainfall_7d_mm: float
    distance_to_river_km: float
    river_discharge_cusecs: float
    flood_depth_m: float
    magnitude: float
    earthquake_depth_km: float
    distance_to_epicenter_km: float
    pga_g: float
    population_total: float
    urban_ratio: float
    households: float
    poverty_rate: float
    buildings_total: float
    housing_quality_index: float
    building_material: str
    farmland_area_hectares: float
    livestock_count: float

@app.post("/predict")
async def predict_impact(event: DisasterEvent):
    # Safety Check: Ensure models loaded correctly
    if not models or encoders is None:
        raise HTTPException(status_code=500, detail="Models or Encoders not initialized on server.")

    try:
        df = pd.DataFrame([event.dict()])

        # Feature Engineering (Matching Colab logic exactly)
        df['vulnerability_score'] = (df['poverty_rate'] * 0.4 + 
                                    (1 - df['housing_quality_index']) * 0.4 + 
                                    (1 - df['urban_ratio']) * 0.2)
        df['flood_exposure'] = df['rainfall_7d_mm'] * df['flood_depth_m']
        df['seismic_exposure'] = df['magnitude'] * df['pga_g']
        df['heat_stress'] = df['temperature_max'] * df['humidity']
        df['rain_intensity'] = df['rainfall_7d_mm'] / 7.0
        df['building_exposure'] = df['buildings_total'] * (1 - df['housing_quality_index'])
        df['pop_density_proxy'] = df['population_total'] / (df['households'] + 1)

        # Categorical Encoding
        categorical_cols = ['province', 'season', 'disaster_type', 'disaster_subtype', 'building_material']
        for col in categorical_cols:
            if col in encoders:
                le = encoders[col]
                # Use the encoder's classes to safely transform
                val = df[col].iloc[0]
                df[col] = le.transform([val])[0] if val in le.classes_ else 0

        # Prediction
        predictions = {}
        X = df[feature_cols] # Ensure feature_cols matches training exactly
        
        for target in TARGETS:
            pred_log = models[target].predict(X)
            # Reverse log1p
            predictions[target] = float(np.expm1(pred_log)[0])

        return {"status": "success", "predictions": predictions}

    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Prediction Error: {str(e)}")
    
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)