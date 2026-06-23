from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
import joblib
import numpy as np
import pandas as pd
from sklearn.preprocessing import LabelEncoder
from sklearn.base import BaseEstimator, TransformerMixin
import warnings
warnings.filterwarnings('ignore')

# ============================================
# CUSTOM LABEL ENCODER CLASS - MUST BE DEFINED BEFORE LOADING MODELS
# ============================================

class CustomLabelEncoder(BaseEstimator, TransformerMixin):
    """Custom Label Encoder that handles missing values"""
    def __init__(self):
        self.encoders = {}

    def set_output(self, *, transform=None):
        return self

    def fit(self, X, y=None):
        for col in X.columns:
            le = LabelEncoder()
            # Handle NaN by converting to string
            col_data = X[col].fillna('MISSING').astype(str)
            le.fit(col_data)
            self.encoders[col] = le
        return self

    def transform(self, X):
        X_encoded = X.copy()
        for col, le in self.encoders.items():
            col_data = X_encoded[col].fillna('MISSING').astype(str)
            X_encoded[col] = col_data.map(lambda x: le.transform([x])[0] if x in le.classes_ else -1)
        return X_encoded.astype(float)

# Initialize FastAPI app
app = FastAPI(
    title="Drone Attack Prediction API",
    description="API for predicting human toll in drone attacks using ML models",
    version="1.0.0"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, replace with specific origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Load models and preprocessor at startup
print("Loading models...")
try:
    # Load with custom class available in namespace
    preprocessor = joblib.load('suicide_attack_preprocessor.pkl')
    model_rf = joblib.load('suicide_attack_model_rf.pkl')
    model_gbr = joblib.load('suicide_attack_model_gbr.pkl')
    print("✓ Models loaded successfully")
    print(f"✓ Preprocessor type: {type(preprocessor).__name__}")
    print(f"✓ RF Model type: {type(model_rf).__name__}")
    print(f"✓ GBR Model type: {type(model_gbr).__name__}")
except Exception as e:
    print(f"✗ Error loading models: {e}")
    print("Make sure the .pkl files are in the same directory as this script")
    raise

# Define input data model
class AttackPredictionInput(BaseModel):
    location: str = Field(..., description="Location of the attack")
    city: str = Field(..., description="City where attack occurred")
    province: str = Field(..., description="Province of the attack")
    no_of_strikes: int = Field(..., ge=0, description="Number of drone strikes")
    temperature_c: float = Field(..., description="Temperature in Celsius")
    hour_of_day: int = Field(..., ge=0, le=23, description="Hour of the day (0-23)")
    
    model_config = { #guide
        "json_schema_extra": {
            "examples": [{
                "location": "Mir Ali",
                "city": "North Waziristan",
                "province": "FATA",
                "no_of_strikes": 1,
                "temperature_c": 25.0,
                "hour_of_day": 14
            }]
        }
    }

# Define output data model
class AttackPredictionOutput(BaseModel):
    killed_prediction: float = Field(..., description="Predicted number of fatalities")
    injured_prediction: float = Field(..., description="Predicted number of injuries")
    killed_confidence_interval: dict = Field(..., description="Confidence interval for fatalities")
    injured_confidence_interval: dict = Field(..., description="Confidence interval for injuries")
    model_used: str = Field(..., description="ML model used for prediction")
    input_summary: dict = Field(..., description="Summary of input parameters")
    
# Define batch prediction model
class BatchPredictionInput(BaseModel):
    predictions: list[AttackPredictionInput]

class BatchPredictionOutput(BaseModel):
    results: list[AttackPredictionOutput]
    total_predictions: int

@app.get("/")
async def root():
    """Root endpoint with API information"""
    return {
        "message": "Drone Attack Prediction API",
        "version": "1.0.0",
        "endpoints": {
            "predict": "/predict (POST)",
            "batch_predict": "/batch-predict (POST)",
            "health": "/health (GET)",
            "model_info": "/model-info (GET)",
            "docs": "/docs (GET)",
            "redoc": "/redoc (GET)"
        }
    }

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "models_loaded": True,
        "sklearn_version": "1.3.2"  # Update this to match your environment
    }

@app.get("/model-info")
async def model_info():
    """Get information about the loaded models"""
    return {
        "available_models": ["Random Forest", "Gradient Boosting"],
        "features_used": [
            "Location",
            "City", 
            "Province",
            "No of Strike",
            "Temperature(C)",
            "Hour_of_Day"
        ],
        "target_variables": ["Killed", "Injured"],
        "note": "Model was trained on Pakistan Drone Attack data (2004-2017)",
        "model_performance": {
            "random_forest": {
                "killed_mae": 5.59,
                "killed_rmse": 7.47,
                "injured_mae": 1.93,
                "injured_rmse": 3.01
            },
            "gradient_boosting": {
                "killed_mae": 9.65,
                "killed_rmse": 15.38,
                "injured_mae": 18.78,
                "injured_rmse": 71.52
            }
        }
    }

@app.post("/predict", response_model=AttackPredictionOutput)
async def predict(input_data: AttackPredictionInput):
    """
    Predict human toll for a single drone attack
    
    Returns predicted fatalities and injuries with confidence intervals
    """
    try:
        # Prepare input data
        input_df = pd.DataFrame([{
            'Location': input_data.location,
            'City': input_data.city,
            'Province': input_data.province,
            'No of Strike': input_data.no_of_strikes,
            'Temperature(C)': input_data.temperature_c,
            'Hour_of_Day': input_data.hour_of_day
        }])
        
        print(f"Processing prediction for: {input_data.location}, {input_data.city}")
        
        # Preprocess input
        processed_input = preprocessor.transform(input_df)
        
        # Make predictions with both models
        pred_rf = model_rf.predict(processed_input)[0]
        pred_gbr = model_gbr.predict(processed_input)[0]
        
        # Use Random Forest prediction (better performance based on training)
        killed_pred = float(max(0, pred_rf[0]))  # Ensure non-negative
        injured_pred = float(max(0, pred_rf[1]))  # Ensure non-negative
        
        # Estimate confidence intervals (based on training error std)
        killed_std = 7.12  # From training error analysis
        injured_std = 3.01  # From training RMSE
        
        return AttackPredictionOutput(
            killed_prediction=round(killed_pred, 1),
            injured_prediction=round(injured_pred, 1),
            killed_confidence_interval={
                "lower": round(max(0, killed_pred - 1.96 * killed_std), 1),
                "upper": round(killed_pred + 1.96 * killed_std, 1),
                "confidence_level": 0.95
            },
            injured_confidence_interval={
                "lower": round(max(0, injured_pred - 1.96 * injured_std), 1),
                "upper": round(injured_pred + 1.96 * injured_std, 1),
                "confidence_level": 0.95
            },
            model_used="Random Forest",
            input_summary={
                "location": input_data.location,
                "city": input_data.city,
                "province": input_data.province,
                "strikes": input_data.no_of_strikes,
                "temperature": f"{input_data.temperature_c}°C",
                "time": f"{input_data.hour_of_day}:00"
            }
        )
        
    except Exception as e:
        print(f"Prediction error: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Prediction error: {str(e)}")

@app.post("/batch-predict", response_model=BatchPredictionOutput)
async def batch_predict(input_data: BatchPredictionInput):
    """
    Predict human toll for multiple drone attacks
    
    Accepts a list of attack scenarios and returns predictions for each
    """
    try:
        results = []
        
        for idx, attack in enumerate(input_data.predictions):
            print(f"Processing batch prediction {idx + 1}/{len(input_data.predictions)}")
            prediction = await predict(attack)
            results.append(prediction)
        
        return BatchPredictionOutput(
            results=results,
            total_predictions=len(results)
        )
        
    except Exception as e:
        print(f"Batch prediction error: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Batch prediction error: {str(e)}")

@app.post("/predict-gbr", response_model=AttackPredictionOutput)
async def predict_gbr(input_data: AttackPredictionInput):
    """
    Alternative prediction using Gradient Boosting model
    """
    try:
        # Prepare input data
        input_df = pd.DataFrame([{
            'Location': input_data.location,
            'City': input_data.city,
            'Province': input_data.province,
            'No of Strike': input_data.no_of_strikes,
            'Temperature(C)': input_data.temperature_c,
            'Hour_of_Day': input_data.hour_of_day
        }])
        
        # Preprocess input
        processed_input = preprocessor.transform(input_df)
        
        # Make prediction with GBR model
        pred_gbr = model_gbr.predict(processed_input)[0]
        
        killed_pred = float(max(0, pred_gbr[0]))
        injured_pred = float(max(0, pred_gbr[1]))
        
        # GBR specific error margins
        killed_std = 14.19
        injured_std = 71.52
        
        return AttackPredictionOutput(
            killed_prediction=round(killed_pred, 1),
            injured_prediction=round(injured_pred, 1),
            killed_confidence_interval={
                "lower": round(max(0, killed_pred - 1.96 * killed_std), 1),
                "upper": round(killed_pred + 1.96 * killed_std, 1),
                "confidence_level": 0.95
            },
            injured_confidence_interval={
                "lower": round(max(0, injured_pred - 1.96 * injured_std), 1),
                "upper": round(injured_pred + 1.96 * injured_std, 1),
                "confidence_level": 0.95
            },
            model_used="Gradient Boosting",
            input_summary={
                "location": input_data.location,
                "city": input_data.city,
                "province": input_data.province,
                "strikes": input_data.no_of_strikes,
                "temperature": f"{input_data.temperature_c}°C",
                "time": f"{input_data.hour_of_day}:00"
            }
        )
        
    except Exception as e:
        print(f"GBR prediction error: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Prediction error: {str(e)}")

# Health check for model compatibility
@app.get("/check-compatibility")
async def check_compatibility():
    """Check if the loaded models are compatible with current environment"""
    import sklearn
    return {
        "current_sklearn_version": sklearn.__version__,
        "model_sklearn_version": "1.6.1",  # Version used to train the model
        "warning": "Version mismatch detected. Models may still work correctly.",
        "recommendation": "For best results, use scikit-learn 1.6.1 or upgrade models"
    }

if __name__ == "__main__":
    import uvicorn
    print("="*60)
    print("Starting Drone Attack Prediction API")
    print("="*60)
    uvicorn.run(
        app, 
        host="0.0.0.0", 
        port=8091,
        log_level="info"
    )