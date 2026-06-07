"""User intake routes."""

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

from models.user import DiseaseTag, UserProfile, get_user, save_user, update_user

router = APIRouter(prefix="/api/v1/user", tags=["user"])


class IntakeInput(BaseModel):
    name: str
    disease_tags: list[DiseaseTag] = []
    symptoms: list[str] = []
    vitals: dict = {}
    lat: float = 0.0
    long: float = 0.0
    device_token: str = ""


class DeviceTokenInput(BaseModel):
    user_id: str
    device_token: str


@router.post("/intake")
def create_user_intake(input: IntakeInput):
    user = UserProfile(**input.model_dump())
    save_user(user)
    return {"user_id": user.id, "message": "User profile created", "message_vi": "Đã tạo hồ sơ người dùng"}


@router.get("/profile/{user_id}")
def get_user_profile(user_id: str):
    user = get_user(user_id)
    if not user:
        raise HTTPException(404, detail="User not found")
    return user.model_dump()


@router.post("/device-token")
def update_device_token(input: DeviceTokenInput):
    user = update_user(input.user_id, device_token=input.device_token)
    if not user:
        raise HTTPException(404, detail="User not found")
    return {"message": "Device token updated", "message_vi": "Đã cập nhật device token"}
