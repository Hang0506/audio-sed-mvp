"""Food scan routes."""

import time
from typing import Optional

from fastapi import APIRouter, HTTPException, UploadFile

from models.user import get_user
from services.food_detector import detect
from services.health_risk import assess_health_risk

router = APIRouter(prefix="/api", tags=["food"])


@router.post("/food-scan")
async def food_scan(file: UploadFile, user_id: Optional[str] = None):
    """Scan food image → detect foods → assess health risk."""
    if not file.content_type or not file.content_type.startswith("image/"):
        raise HTTPException(400, "File must be an image")

    image_bytes = await file.read()
    if not image_bytes:
        raise HTTPException(400, "Empty file")

    start = time.time()
    foods = detect(image_bytes)
    inference_time_ms = (time.time() - start) * 1000

    # Health risk assessment
    user_profile = {}
    if user_id:
        user = get_user(user_id)
        if user:
            user_profile = user.model_dump()

    risk_result = assess_health_risk(foods, user_profile)

    return {
        "foods": foods,
        "total_nutrition": risk_result["total_nutrition"],
        "risk_alerts": risk_result["risk_alerts"],
        "inference_time_ms": round(inference_time_ms, 1),
    }
