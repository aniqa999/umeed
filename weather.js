// src/lib/weather.js
const OPEN_METEO_API = "https://api.open-meteo.com/v1/forecast";

// Weather code to description mapping
const weatherDescriptions = {
  0: { description: "Clear sky", icon: "☀️" },
  1: { description: "Mainly clear", icon: "🌤️" },
  2: { description: "Partly cloudy", icon: "⛅" },
  3: { description: "Overcast", icon: "☁️" },
  45: { description: "Fog", icon: "🌫️" },
  48: { description: "Depositing rime fog", icon: "🌫️" },
  51: { description: "Light drizzle", icon: "🌦️" },
  53: { description: "Moderate drizzle", icon: "🌦️" },
  55: { description: "Dense drizzle", icon: "🌧️" },
  56: { description: "Freezing drizzle", icon: "🌨️" },
  57: { description: "Dense freezing drizzle", icon: "🌨️" },
  61: { description: "Slight rain", icon: "🌧️" },
  63: { description: "Moderate rain", icon: "🌧️" },
  65: { description: "Heavy rain", icon: "⛈️" },
  66: { description: "Freezing rain", icon: "🌨️" },
  67: { description: "Heavy freezing rain", icon: "🌨️" },
  71: { description: "Slight snow", icon: "🌨️" },
  73: { description: "Moderate snow", icon: "❄️" },
  75: { description: "Heavy snow", icon: "❄️" },
  77: { description: "Snow grains", icon: "🌨️" },
  80: { description: "Slight rain showers", icon: "🌦️" },
  81: { description: "Moderate rain showers", icon: "🌧️" },
  82: { description: "Violent rain showers", icon: "⛈️" },
  85: { description: "Slight snow showers", icon: "🌨️" },
  86: { description: "Heavy snow showers", icon: "❄️" },
  95: { description: "Thunderstorm", icon: "⛈️" },
  96: { description: "Thunderstorm with hail", icon: "⛈️" },
  99: { description: "Thunderstorm with heavy hail", icon: "⛈️" },
};

/**
 * Fetches current weather data for given coordinates
 */
export async function fetchWeatherData(lat, lng) {
  try {
    const params = new URLSearchParams({
      latitude: lat.toString(),
      longitude: lng.toString(),
      current: "temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m",
      timezone: "auto",
    });

    const response = await fetch(`${OPEN_METEO_API}?${params}`);

    if (!response.ok) {
      throw new Error("Failed to fetch weather data");
    }

    const data = await response.json();
    const current = data.current;

    const weatherInfo = weatherDescriptions[current.weather_code] || {
      description: "Unknown",
      icon: "❓",
    };

    return {
      temperature: Math.round(current.temperature_2m),
      humidity: current.relative_humidity_2m,
      windSpeed: Math.round(current.wind_speed_10m),
      weatherCode: current.weather_code,
      precipitation: current.precipitation,
      feelsLike: Math.round(current.apparent_temperature),
      description: weatherInfo.description,
      icon: weatherInfo.icon,
    };
  } catch (error) {
    console.error("Weather fetch error:", error);
    return null;
  }
}

/**
 * Determines alert level based on weather code and disaster context
 */
export function getWeatherAlertLevel(weatherCode, disasterType) {
  // Check for dangerous weather conditions based on disaster type
  const dangerCodes = [65, 66, 67, 75, 82, 86, 95, 96, 99]; // Heavy rain, snow, thunderstorms
  const warningCodes = [61, 63, 71, 73, 80, 81, 85]; // Moderate precipitation

  if (disasterType === "Flood" && [61, 63, 65, 80, 81, 82].includes(weatherCode)) {
    return "danger";
  }
  if (disasterType === "Landslide" && [63, 65, 82].includes(weatherCode)) {
    return "danger";
  }
  if (dangerCodes.includes(weatherCode)) {
    return "danger";
  }
  if (warningCodes.includes(weatherCode)) {
    return "warning";
  }
  return "none";
}