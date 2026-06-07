"""Context aggregator — fetches weather/air quality from OpenWeatherMap."""

import os
import time
from pathlib import Path
from typing import Optional

from dotenv import load_dotenv
import httpx

load_dotenv(Path(__file__).parent.parent / ".env")
API_KEY = os.getenv("OPENWEATHERMAP_API_KEY", "")

# In-memory cache: key=(lat,long) -> {data, timestamp}
_cache: dict[tuple[float, float], dict] = {}
_CACHE_TTL = 1800  # 30 minutes


def _mock_weather() -> dict:
    return {
        "temperature": 32,
        "humidity": 78,
        "pm25": 85.0,
        "aqi": 4,
        "timestamp": time.time(),
        "location_name": "Ho Chi Minh City (mock)",
    }


async def fetch_weather(lat: float, long: float) -> dict:
    key = (round(lat, 2), round(long, 2))

    # Return cache if fresh
    if key in _cache and (time.time() - _cache[key]["timestamp"]) < _CACHE_TTL:
        return _cache[key]

    if not API_KEY:
        data = _mock_weather()
        _cache[key] = data
        return data

    try:
        async with httpx.AsyncClient(timeout=10) as client:
            # Air pollution API
            air_resp = await client.get(
                "http://api.openweathermap.org/data/2.5/air_pollution",
                params={"lat": lat, "lon": long, "appid": API_KEY},
            )
            air_resp.raise_for_status()
            air = air_resp.json()

            # Weather API
            weather_resp = await client.get(
                "http://api.openweathermap.org/data/2.5/weather",
                params={"lat": lat, "lon": long, "appid": API_KEY, "units": "metric"},
            )
            weather_resp.raise_for_status()
            weather = weather_resp.json()

        components = air["list"][0]["components"]
        data = {
            "temperature": weather["main"]["temp"],
            "humidity": weather["main"]["humidity"],
            "pm25": components.get("pm2_5", 0),
            "aqi": air["list"][0]["main"]["aqi"],
            "timestamp": time.time(),
            "location_name": weather.get("name", "Unknown"),
        }
        _cache[key] = data
        return data

    except Exception:
        # Fallback to last cached value or mock
        if key in _cache:
            return _cache[key]
        return _mock_weather()
