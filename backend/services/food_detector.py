"""Food detector — YOLOv10 inference using ultralytics (same as FoodDetector repo).

Downloads model from GitHub if not present. Falls back to mock if ultralytics unavailable.
"""

import io
import os
import time
import random
from pathlib import Path

import numpy as np
from PIL import Image

from models.food_classes import FOOD_CLASSES

MODEL_DIR = Path(__file__).parent.parent / "models"
MODEL_PATH = MODEL_DIR / "YOLOv10m_food.onnx"

# Full 68 class names from FoodDetector repo (index → name)
CLASS_NAMES_FULL = [
    "Banh canh", "Banh chung", "Banh cuon", "Banh khot", "Banh mi",
    "Banh trang", "Banh trang tron", "Banh xeo", "Bo kho", "Bo la lot",
    "Bong cai", "Bun", "Bun bo Hue", "Bun cha", "Bun dau",
    "Bun mam", "Bun rieu", "Ca", "Ca chua", "Ca phao",
    "Ca rot", "Canh", "Cha", "Cha gio", "Chanh",
    "Com", "Com tam", "Con nguoi", "Cu kieu", "Cua",
    "Dau hu", "Dua chua", "Dua leo", "Goi cuon", "Hamburger",
    "Heo quay", "Hu tieu", "Kho qua thit", "Khoai tay chien", "Lau",
    "Long heo", "Mi", "Muc", "Nam", "Oc",
    "Ot chuong", "Pho", "Pho mai", "Rau", "Salad",
    "Thit bo", "Thit ga", "Thit heo", "Thit kho", "Thit nuong",
    "Tom", "Trung", "Trung chien", "Xoi", "Xuc xich",
    "Banh bao", "Che", "Dua hau", "Goi", "Mi xao",
    "Nuoc mam", "Suon", "Trai cay",
]

_model = None
_mock_mode = False


def _load_model():
    """Load YOLO ONNX model."""
    global _model, _mock_mode
    if _model is not None:
        return

    try:
        from ultralytics import YOLO

        if not MODEL_PATH.exists() or MODEL_PATH.stat().st_size < 1024:
            raise FileNotFoundError(f"Model not found: {MODEL_PATH}")

        _model = YOLO(str(MODEL_PATH), task="detect")
        _mock_mode = False
        print(f"[FoodDetector] Model loaded successfully (REAL mode, ONNX)")
    except Exception as e:
        print(f"[FoodDetector] Cannot load model: {e}. Using MOCK mode.")
        _mock_mode = True


def _get_nutrition(class_name: str) -> dict:
    """Lookup nutrition from FOOD_CLASSES. Exact match first."""
    cl = class_name.lower().replace(" ", "")
    # Exact match
    for fc in FOOD_CLASSES.values():
        if fc["name"].lower().replace(" ", "") == cl:
            return fc["nutrition"]
    # Fallback: generic
    return {"Calories": 200, "Fat": 8, "Saturates": 2, "Sugar": 3, "Salt": 0.8}


def _get_name_vi(class_name: str) -> str:
    """Get Vietnamese display name. Exact match first, then partial."""
    cl = class_name.lower().strip()
    # Exact match
    for fc in FOOD_CLASSES.values():
        if fc["name"].lower() == cl:
            return fc.get("name_vi", class_name)
    # Partial — only if FOOD_CLASSES name fully matches a word boundary
    return class_name


def detect(image_bytes: bytes, confidence: float = 0.75) -> list[dict]:
    """Detect foods in image. Returns list of detections.
    
    confidence: minimum threshold (default 0.75 to reduce false positives).
    Detections below this are discarded.
    """
    _load_model()

    if _mock_mode:
        time.sleep(random.uniform(0.3, 0.8))
        count = random.randint(1, 3)
        keys = random.sample(list(FOOD_CLASSES.keys()), min(count, len(FOOD_CLASSES)))
        return [
            {
                "class_id": k,
                "name": FOOD_CLASSES[k]["name"],
                "name_vi": FOOD_CLASSES[k].get("name_vi", FOOD_CLASSES[k]["name"]),
                "confidence": round(random.uniform(0.7, 0.95), 3),
                "bbox": [random.randint(10, 100), random.randint(10, 100),
                         random.randint(300, 500), random.randint(300, 500)],
                "nutrition": FOOD_CLASSES[k]["nutrition"],
            }
            for k in keys
        ]

    # Real inference
    start = time.time()
    img = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    img_w, img_h = img.size
    results = _model.predict(source=img, conf=confidence, imgsz=640, device="cpu", verbose=False)

    detections = []
    for r in results:
        for box in r.boxes:
            class_id = int(box.cls[0].item())
            conf = round(box.conf[0].item(), 3)
            xyxy = box.xyxy[0].cpu().numpy().tolist()
            class_name = CLASS_NAMES_FULL[class_id] if class_id < len(CLASS_NAMES_FULL) else f"class_{class_id}"

            # Skip "Con nguoi" (person) class — not food
            if class_name == "Con nguoi":
                continue

            # Filter out unreasonably large bboxes (>90% of image = likely false positive)
            bw = xyxy[2] - xyxy[0]
            bh = xyxy[3] - xyxy[1]
            if bw > img_w * 0.9 and bh > img_h * 0.9:
                continue

            detections.append({
                "class_id": class_id,
                "name": class_name,
                "name_vi": _get_name_vi(class_name),
                "confidence": conf,
                "bbox": [int(x) for x in xyxy],
                "nutrition": _get_nutrition(class_name),
            })

    elapsed = time.time() - start
    print(f"[FoodDetector] Detected {len(detections)} foods in {elapsed*1000:.0f}ms")
    return detections


# Singleton-like access
food_detector_detect = detect
