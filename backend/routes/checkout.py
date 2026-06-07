"""O2O Checkout & Analytics API routes."""

import json
import uuid
from datetime import datetime
from pathlib import Path

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

router = APIRouter()

STORAGE_DIR = Path(__file__).parent.parent / "storage"
ORDERS_FILE = STORAGE_DIR / "orders.json"
ANALYTICS_FILE = STORAGE_DIR / "analytics.json"


# --- Models ---

class CreateOrderInput(BaseModel):
    user_id: str
    product_id: str
    product_name: str
    quantity: int = 1
    source_alert_id: str | None = None
    delivery_lat: float
    delivery_long: float


class AnalyticsEventInput(BaseModel):
    event_type: str
    user_id: str
    metadata: dict = {}


# --- Helpers ---

def _read_json(path: Path) -> list:
    if not path.exists():
        return []
    return json.loads(path.read_text(encoding="utf-8"))


def _append_json(path: Path, item: dict):
    data = _read_json(path)
    data.append(item)
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")


# --- Routes ---

@router.post("/api/v1/order/create")
def create_order(input: CreateOrderInput):
    order_id = str(uuid.uuid4())[:8]
    order = {
        "order_id": order_id,
        "user_id": input.user_id,
        "product_id": input.product_id,
        "product_name": input.product_name,
        "quantity": input.quantity,
        "source_alert_id": input.source_alert_id,
        "delivery_lat": input.delivery_lat,
        "delivery_long": input.delivery_long,
        "status": "confirmed",
        "created_at": datetime.now().isoformat(),
    }
    _append_json(ORDERS_FILE, order)
    return {
        "order_id": order_id,
        "status": "confirmed",
        "estimated_delivery": "15 phút",
        "message_vi": f"Đơn hàng {input.product_name} đã được xác nhận. Giao hàng trong khoảng 15 phút.",
    }


@router.get("/api/v1/order/{order_id}")
def get_order(order_id: str):
    orders = _read_json(ORDERS_FILE)
    for o in orders:
        if o["order_id"] == order_id:
            return o
    raise HTTPException(404, "Không tìm thấy đơn hàng")


@router.post("/api/v1/analytics/event")
def track_event(input: AnalyticsEventInput):
    event = {
        "event_type": input.event_type,
        "user_id": input.user_id,
        "metadata": input.metadata,
        "timestamp": datetime.now().isoformat(),
    }
    _append_json(ANALYTICS_FILE, event)
    return {"status": "ok", "message_vi": "Sự kiện đã được ghi nhận."}
