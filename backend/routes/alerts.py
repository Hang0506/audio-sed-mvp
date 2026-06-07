"""Alerts evaluation API route."""

from fastapi import APIRouter
from pydantic import BaseModel

from services.rule_engine import evaluate_rules

router = APIRouter()

# In-memory mock user profiles for MVP testing
_MOCK_PROFILES = {
    "user_001": {"disease_tags": ["ENT", "Rhinitis"], "device_token": "fcm_token_abc123"},
    "user_002": {"disease_tags": ["Gout"], "device_token": "fcm_token_def456"},
    "user_003": {"disease_tags": ["Diabetes_T2"], "device_token": "fcm_token_ghi789"},
}

# Mock context (would come from weather API in production)
_MOCK_CONTEXT = {
    "pm25": 180,
    "humidity": 90,
    "temperature": 37,
}


class EvaluateInput(BaseModel):
    user_id: str
    context_data: dict | None = None


@router.post("/api/v1/alerts/evaluate")
def evaluate_alerts(input: EvaluateInput):
    profile = _MOCK_PROFILES.get(input.user_id, {"disease_tags": []})
    context = input.context_data or _MOCK_CONTEXT
    triggered = evaluate_rules(profile, context)
    return {"user_id": input.user_id, "alerts": triggered, "count": len(triggered)}
