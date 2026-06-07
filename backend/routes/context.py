"""Context aggregation routes."""

from fastapi import APIRouter, HTTPException

from models.user import get_user
from services.context_aggregator import fetch_weather

router = APIRouter(prefix="/api/v1/context", tags=["context"])


@router.get("/{user_id}")
async def get_user_context(user_id: str):
    user = get_user(user_id)
    if not user:
        raise HTTPException(404, detail="User not found")

    weather = await fetch_weather(user.lat, user.long)
    return {
        "user_id": user_id,
        "weather": weather,
        "disease_tags": user.disease_tags,
        "symptoms": user.symptoms,
        "vitals": user.vitals,
        "message_vi": "Dữ liệu ngữ cảnh sức khỏe",
    }
