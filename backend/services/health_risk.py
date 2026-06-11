"""Health risk assessment based on detected foods and user profile."""

import json
from pathlib import Path

from models.food_classes import FOOD_CLASSES

PURINE_DB_PATH = Path(__file__).parent.parent / "models" / "purine_db.json"
ENT_DB_PATH = Path(__file__).parent.parent / "models" / "ent_food_db.json"
_purine_db: dict = {}
_ent_db: dict = {}


def _load_purine_db() -> dict:
    global _purine_db
    if not _purine_db:
        _purine_db = json.loads(PURINE_DB_PATH.read_text(encoding="utf-8"))
    return _purine_db


def _load_ent_db() -> dict:
    global _ent_db
    if not _ent_db:
        _ent_db = json.loads(ENT_DB_PATH.read_text(encoding="utf-8"))
    return _ent_db


def assess_health_risk(detected_foods: list[dict], user_profile: dict) -> dict:
    """Assess health risks based on detected foods and user conditions."""
    tags = set(user_profile.get("disease_tags", []))
    purine = _load_purine_db()
    ent_db = _load_ent_db()
    alerts: list[dict] = []
    total = {"Calories": 0, "Fat": 0, "Saturates": 0, "Sugar": 0, "Salt": 0}

    for food in detected_foods:
        nutr = food.get("nutrition", {})
        for k in total:
            total[k] += nutr.get(k, 0)
        name = food.get("name", "")
        name_vi = food.get("name_vi", name)

        # Gout + high purine
        if "Gout" in tags and name in purine.get("high_purine", []):
            alerts.append({
                "type": "purine", "severity": "danger",
                "message_vi": f"⚠️ {name_vi} chứa nhiều purine — nguy cơ cao cho bệnh Gout",
                "food_name": name_vi,
            })

        # Diabetes + high sugar/calories
        if "Diabetes_T2" in tags:
            if nutr.get("Sugar", 0) > 10:
                alerts.append({
                    "type": "sugar", "severity": "warning",
                    "message_vi": f"🍬 {name_vi} chứa {nutr['Sugar']}g đường — cần kiểm soát",
                    "food_name": name_vi,
                })
            if nutr.get("Calories", 0) > 500:
                alerts.append({
                    "type": "calories", "severity": "warning",
                    "message_vi": f"🔥 {name_vi} có {nutr['Calories']} kcal — vượt mức khuyến nghị",
                    "food_name": name_vi,
                })

        # Hypertension + high salt
        if "Hypertension" in tags and nutr.get("Salt", 0) > 1.5:
            alerts.append({
                "type": "salt", "severity": "warning",
                "message_vi": f"🧂 {name_vi} chứa {nutr['Salt']}g muối — cần hạn chế",
                "food_name": name_vi,
            })

        # ENT — cảnh báo dựa trên tên món ăn (không cần user có tag ENT)
        if "ENT" in tags:
            for risk_type, risk_info in ent_db.items():
                if name in risk_info["foods"]:
                    alerts.append({
                        "type": f"ent_{risk_type}",
                        "severity": risk_info["severity"],
                        "message_vi": risk_info["message_template"].format(name_vi=name_vi),
                        "food_name": name_vi,
                    })

    return {"risk_alerts": alerts, "total_nutrition": total}
