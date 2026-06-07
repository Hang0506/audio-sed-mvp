# Stage 1 Done — Backend Core APIs

> Completed: 2026-06-05

## API Endpoints Created

| Method | Path | Request | Response |
|--------|------|---------|----------|
| POST | /api/v1/user/intake | `{name, disease_tags[], symptoms[], vitals{}, lat, long, device_token}` | `{id, ...profile, message_vi}` |
| GET | /api/v1/user/profile/{user_id} | — | `{...full UserProfile}` |
| POST | /api/v1/user/device-token | `{user_id, device_token}` | `{success, message_vi}` |
| GET | /api/v1/context/{user_id} | — | `{temperature, humidity, pm25, aqi, timestamp, location_name, health_context{}}` |
| POST | /api/sleep-assessment | `{snoring_freq, daytime_sleepiness, apnea_observed, body_type, sleep_symptoms[]}` | `{classification, risk_score, recommendations[], warnings[], should_see_doctor}` |
| POST | /api/v1/alerts/evaluate | `{user_id, context_data?}` | `{user_id, alerts[], count}` |

## Existing Endpoints (unchanged)

| Method | Path | Purpose |
|--------|------|---------|
| POST | /api/analyze | Audio analysis (YAMNet + CoughTypeV2) |
| POST | /api/recommendation | Cough recommendation engine |
| GET | /api/recommendation/options | Form options for assessment |
| GET | /api/samples | List sample WAV files |
| GET | /api/samples/{filename} | Download sample WAV |

## DB Schema

UserProfile stored in `backend/storage/users.json`:
```json
{
  "id": "uuid",
  "name": "string",
  "device_token": "string",
  "lat": 0.0,
  "long": 0.0,
  "disease_tags": ["ENT", "Gout", "Diabetes_T2", "Hypertension"],
  "symptoms": ["string"],
  "vitals": {},
  "created_at": "ISO 8601"
}
```

## Rule Config Format

`backend/config/rules.json`:
- Rules: conditions (field/operator/value) + template_id + priority
- Templates: title (Vietnamese) + body + deeplink
- Operators: gt, lt, gte, lte, eq, contains

## Dependencies Added

- httpx>=0.27.0 (async HTTP client for OpenWeatherMap)
- firebase-admin (optional, mock mode when not installed)

## Environment Variables

| Var | Default | Purpose |
|-----|---------|---------|
| OPENWEATHERMAP_API_KEY | "" (mock mode) | Weather + Air Quality API |
| FIREBASE_CREDENTIALS_PATH | "" (mock mode) | FCM push notifications |

## Context7 Versions Verified

- FastAPI 0.115+ (async patterns, APIRouter, Pydantic V2)
- httpx 0.27+ (async client)
- firebase-admin 6.x (FCM v1 API)

## Files Created/Modified

- backend/models/user.py
- backend/routes/__init__.py
- backend/routes/intake.py
- backend/routes/context.py
- backend/routes/sleep.py
- backend/routes/alerts.py
- backend/services/__init__.py
- backend/services/context_aggregator.py
- backend/services/rule_engine.py
- backend/services/alert_dispatcher.py
- backend/config/__init__.py
- backend/config/rules.json
- backend/app.py (updated — added CORS + 4 routers)
- backend/requirements.txt (added httpx)
