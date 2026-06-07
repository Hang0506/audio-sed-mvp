"""User profile model with JSON file storage."""

import json
import uuid
from datetime import datetime
from enum import Enum
from pathlib import Path
from typing import Optional

from pydantic import BaseModel, Field

STORAGE_PATH = Path(__file__).parent.parent / "storage" / "users.json"


class DiseaseTag(str, Enum):
    ENT = "ENT"
    Gout = "Gout"
    Diabetes_T2 = "Diabetes_T2"
    Hypertension = "Hypertension"


class UserProfile(BaseModel):
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    name: str
    device_token: str = ""
    lat: float = 0.0
    long: float = 0.0
    disease_tags: list[DiseaseTag] = []
    symptoms: list[str] = []
    vitals: dict = {}
    created_at: str = Field(default_factory=lambda: datetime.utcnow().isoformat())


def _load_db() -> dict[str, dict]:
    if STORAGE_PATH.exists():
        return json.loads(STORAGE_PATH.read_text(encoding="utf-8"))
    return {}


def _save_db(db: dict[str, dict]):
    STORAGE_PATH.parent.mkdir(parents=True, exist_ok=True)
    STORAGE_PATH.write_text(json.dumps(db, ensure_ascii=False, indent=2), encoding="utf-8")


def save_user(user: UserProfile) -> UserProfile:
    db = _load_db()
    db[user.id] = user.model_dump()
    _save_db(db)
    return user


def get_user(user_id: str) -> Optional[UserProfile]:
    db = _load_db()
    if user_id in db:
        return UserProfile(**db[user_id])
    return None


def update_user(user_id: str, **kwargs) -> Optional[UserProfile]:
    db = _load_db()
    if user_id not in db:
        return None
    db[user_id].update(kwargs)
    _save_db(db)
    return UserProfile(**db[user_id])


def list_active_users() -> list[UserProfile]:
    return [UserProfile(**v) for v in _load_db().values()]
