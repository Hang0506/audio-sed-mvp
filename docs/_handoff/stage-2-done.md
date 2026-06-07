# Stage 2 Done — Backend AI APIs

> Completed: 2026-06-05

## New API Endpoints

| Method | Path | Request | Response |
|--------|------|---------|----------|
| POST | /api/food-scan | multipart image + ?user_id= | `{foods[], total_nutrition, risk_alerts[], inference_time_ms}` |
| POST | /api/v1/order/create | `{user_id, product_id, product_name, quantity, delivery_lat, delivery_long}` | `{order_id, status, estimated_delivery, message_vi}` |
| GET | /api/v1/order/{order_id} | — | `{order details}` |
| POST | /api/v1/analytics/event | `{event_type, user_id, metadata{}}` | `{success}` |

## Food Detection Response Shape

```json
{
  "foods": [
    {
      "class_id": 0,
      "name": "Pho",
      "name_vi": "Phở",
      "confidence": 0.89,
      "bbox": [100, 50, 400, 350],
      "nutrition": {"Calories": 450, "Fat": 15, "Saturates": 5, "Sugar": 3, "Salt": 1.8}
    }
  ],
  "total_nutrition": {"Calories": 450, "Fat": 15, "Saturates": 5, "Sugar": 3, "Salt": 1.8},
  "risk_alerts": [
    {
      "type": "purine_high",
      "severity": "danger",
      "message_vi": "⚠️ Món Tôm giàu Purine — nguy cơ kích hoạt flare Gút",
      "food_name": "Tom"
    }
  ],
  "inference_time_ms": 450
}
```

## Health Risk Alert Types

| User Tag | Trigger | Severity | Message |
|----------|---------|----------|---------|
| Gout | high_purine food | danger | Purine warning |
| Gout | moderate_purine food | warning | Moderate purine notice |
| Diabetes_T2 | Sugar > 10g or Calories > 500 | warning | Sugar/calorie warning |
| Hypertension | Salt > 1.5g | warning | Salt warning |
| ENT | spicy food flag | warning | Respiratory irritant warning |

## Checkout Order Response

```json
{
  "order_id": "uuid",
  "status": "confirmed",
  "estimated_delivery": "15 phút",
  "message_vi": "Đơn hàng đã xác nhận. Giao hàng dự kiến trong 15 phút."
}
```

## Environment Variables (new)

| Var | Default | Purpose |
|-----|---------|---------|
| TELEGRAM_BOT_TOKEN | "" (mock) | Telegram bot for Ops food labeling |
| TELEGRAM_CHAT_ID | "" (mock) | Target chat for food images |

## Mock Mode Notes

- Food detector: ONNX model file `backend/models/yolov10_food.onnx` not present → auto-mock mode returning 1-3 random Vietnamese foods
- Telegram: no tokens → logs push intent only
- All mock responses have realistic data and timing

## Files Created

- backend/models/food_classes.py (20 Vietnamese foods with nutrition)
- backend/models/purine_db.json (high/moderate/low classification)
- backend/services/food_detector.py (FoodDetector class + mock)
- backend/services/health_risk.py (assess_health_risk per user profile)
- backend/services/telegram_ops.py (push_to_telegram + mock)
- backend/routes/food.py (POST /api/food-scan)
- backend/routes/checkout.py (order + analytics endpoints)
- backend/app.py (added food_router + checkout_router)
