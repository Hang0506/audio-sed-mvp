# AI Health 360 — Execution Prompt

> Auto-generated from plan: `docs/plan.md` + `docs/task.md`
> Stages: 4 | Total deliverables: 23 tasks (10 BE + 13 FE)

## TASK

Build AI Health 360 MVP — iOS app + Python backend: context-aware health alerts, real-time audio analysis (cough/snore), food detection (YOLOv10), O2O pharmacy checkout. Validate user behavior & money flow trong 4 tuần.

## WORKING DIR

`D:\AI\longchau-audio-sed-mvp`

## CONTEXT (≤ 5 dòng)

- Backend Python FastAPI đã có sẵn: YAMNet ONNX (ho/ngáy/thở), Cough Type V2 (khan/đờm), Sleep OSA screening, Recommendation engine
- Food Detection: tích hợp FoodDetector repo (YOLOv10, VietFood67, 67 classes, mAP50=0.92, có sẵn nutrition data)
- iOS app dùng SwiftUI, dark mode, design tokens từ `docs/presentation-health360-app.html`
- Backend mở rộng thêm: User Intake, Context Aggregator (PM2.5), Rule Engine, FCM, O2O Checkout, Health Risk Engine
- Gamification chỉ UI fake (không build ví/exchange thật)

## CONSTRAINTS

- iOS 16+ minimum, SwiftUI only (no UIKit)
- Backend: Python FastAPI, giữ nguyên code existing (`app.py`, `yamnet_inference.py`, `cough_type_v2.py`, `sleep_recommendation.py`, `cough_recommendation.py`)
- Dark mode first (colors từ design system HTML)
- Không dùng AI phức tạp upfront — YOLOv10 ONNX + YAMNet ONNX là đủ
- All API responses phải có cả English key + Vietnamese display text
- Offline fallback: cache last-known context data locally
- No breaking changes cho existing `/api/analyze` và `/api/recommendation` endpoints

## EXECUTION — 4-STAGE CHAIN

> ⚠️ Đây là orchestrator prompt. Chạy từng stage tuần tự. Mỗi stage = 1 sub-agent DAG blocking.

---

### Stage 1: Backend Core APIs (BE-1, BE-2, BE-3, BE-4, BE-7)

**Sub-agents**: 2 parallel

- Agent 1 (backend-data): BE-1 (User Intake API) + BE-2 (Context Aggregator) — data layer & external API integration
- Agent 2 (backend-logic): BE-3 (Rule Engine) + BE-4 (FCM Alert) + BE-7 (Sleep API expose) — business logic & notification

**Context7 validation** (mỗi agent tự chạy trước khi code):
- `resolve-library-id("FastAPI")` + `query-docs` → verify async patterns, dependency injection
- `resolve-library-id("firebase-admin python")` → verify FCM send message API mới nhất
- `resolve-library-id("APScheduler")` hoặc cronjob pattern cho Context Aggregator
- Ghi kết quả vào SDD

**SDD**: Ghi design decisions vào `docs/design/health360-backend.html`

**Key files to read** (agent tự đọc):
- `backend/app.py` — existing FastAPI app, endpoints, startup
- `backend/sleep_recommendation.py` — module cần wire vào API
- `backend/cough_recommendation.py` — reference pattern cho recommendation response format
- `backend/yamnet_inference.py` — reference pattern cho model loading + inference

**Deliverables**:
- `backend/models/user.py` — User schema + DB operations
- `backend/routes/intake.py` — POST/GET user intake APIs
- `backend/services/context_aggregator.py` — OpenWeatherMap integration + cronjob
- `backend/services/rule_engine.py` — evaluateRules() + JSON rule config
- `backend/services/alert_dispatcher.py` — FCM push notification
- `backend/routes/sleep.py` — Sleep assessment endpoint
- `backend/config/rules.json` — Rule definitions (ENT+PM2.5, Gout+Humidity, etc.)
- Update `backend/app.py` — mount new routes

**Exit gate** (verify ALL):
- [ ] `POST /api/v1/user/intake` → 200 + DB stores disease_tags
- [ ] `GET /api/v1/context/{user_id}` → returns PM2.5 data (mock hoặc real API)
- [ ] `POST /api/sleep-assessment` → returns OSA risk + recommendations
- [ ] Rule engine unit test: ENT + PM2.5>150 → triggerAlert=true
- [ ] All existing tests still pass (`/api/analyze`, `/api/recommendation`)
- [ ] Scope completeness: mọi deliverable = ✅

**Handoff**: Ghi vào `docs/_handoff/stage-1-done.md`:
- API endpoints created (method + path + request/response shape)
- DB schema confirmed
- Rule config format
- Context7 versions verified

---

### Stage 2: Backend AI APIs (BE-5, BE-8, BE-9, BE-6)

**Reads**: `docs/_handoff/stage-1-done.md`

**Assumes done** (không re-implement):
- User intake API working
- Context aggregator fetching PM2.5
- Rule engine + FCM alert working
- Sleep assessment endpoint live

**Sub-agents**: 2 parallel

- Agent 1 (ai-food): BE-8 (Food Detection YOLOv10 API) + BE-9 (Health Risk Engine) — food scan pipeline
- Agent 2 (o2o-ops): BE-5 (Mock AI via Telegram) + BE-6 (O2O Checkout API) — monetization layer

**Context7 validation**:
- `resolve-library-id("onnxruntime")` → verify ONNX inference patterns for YOLOv10
- `resolve-library-id("Pillow")` → image preprocessing
- `resolve-library-id("python-telegram-bot")` → Telegram webhook API
- Ghi kết quả vào SDD

**SDD**: Append to `docs/design/health360-backend.html`

**Key files to read**:
- `backend/yamnet_inference.py` — reference: how existing ONNX model is loaded + used
- FoodDetector `class_names.py` — 67 classes + nutrition data (copy vào project)
- FoodDetector `utils.py` — traffic light logic, nutrient scoring

**Deliverables**:
- `backend/models/food_classes.py` — 67 Vietnamese food classes + nutrition data
- `backend/services/food_detector.py` — YOLOv10 ONNX inference wrapper
- `backend/services/health_risk.py` — Purine/Glycemic/Salt risk per food × user profile
- `backend/routes/food.py` — POST /api/food-scan endpoint
- `backend/services/telegram_ops.py` — Push image to Telegram for manual labeling
- `backend/routes/checkout.py` — O2O order intent + analytics
- `backend/models/purine_db.json` — Purine classification per food class

**Exit gate**:
- [ ] `POST /api/food-scan` with image → returns detected foods + nutrition + risk_alerts
- [ ] Inference time < 5s on CPU
- [ ] Health Risk: user Gout + food "Tom" (shrimp) → returns purine alert
- [ ] `POST /api/v1/order/create` → stores order intent + returns confirmation
- [ ] All existing endpoints unbroken
- [ ] Scope completeness: mọi deliverable = ✅

**Handoff**: `docs/_handoff/stage-2-done.md`

---

### Stage 3: iOS App — Core Screens (FE-1, FE-2, FE-3, FE-4, FE-9)

**Reads**: `docs/_handoff/stage-1-done.md`, `docs/_handoff/stage-2-done.md`

**Assumes done**:
- All backend APIs working (intake, context, rule engine, FCM, food-scan, checkout)
- API contracts confirmed in handoff files

**Sub-agents**: 2 parallel

- Agent 1 (ios-foundation): FE-1 (Layout + Permissions + Design System) + FE-2 (Intake Wizard) + FE-4 (Push Notifications)
- Agent 2 (ios-home): FE-3 (Dashboard Home Screen) + FE-9 (Express Checkout Screen)

**Context7 validation**:
- `resolve-library-id("SwiftUI")` → verify TabView, NavigationStack, Charts patterns
- `resolve-library-id("Firebase iOS SDK")` → verify FCM registration + handling
- `resolve-library-id("CoreLocation")` → verify background location updates
- Ghi kết quả vào SDD

**SDD**: `docs/design/health360-ios.html`

**Key files to read**:
- `docs/presentation-health360-app.html` — ALL screen designs, colors, component structure
- `docs/_handoff/stage-1-done.md` — API contracts to call
- `docs/_handoff/stage-2-done.md` — Food/Checkout API contracts

**Deliverables** (iOS Xcode project at `ios/Health360/`):
- `ios/Health360/App/Health360App.swift` — entry point + Firebase setup
- `ios/Health360/Design/DesignSystem.swift` — colors, fonts, spacing tokens
- `ios/Health360/Design/Components/` — CircularGauge, AlertCard, ContextTile, BadgeTag, TaskCheckRow
- `ios/Health360/Views/MainTabView.swift` — 5-tab navigation
- `ios/Health360/Views/Home/DashboardView.swift` — full dashboard
- `ios/Health360/Views/Profile/IntakeWizardView.swift` — onboarding form
- `ios/Health360/Views/Checkout/ExpressCheckoutView.swift` — O2O purchase
- `ios/Health360/Services/APIClient.swift` — networking layer
- `ios/Health360/Services/NotificationManager.swift` — FCM handling
- `ios/Health360/Models/` — User, ContextData, Alert, Product models

**Exit gate**:
- [ ] Xcode project builds without errors (iOS 16+)
- [ ] 5 tabs render correctly in dark mode
- [ ] Intake form submits to backend API successfully
- [ ] Dashboard shows mock data with correct design (match HTML prototype)
- [ ] Push notification received and handled (deep-link to correct screen)
- [ ] Checkout screen displays product + GPS + confirm button
- [ ] Scope completeness: mọi deliverable = ✅

**Handoff**: `docs/_handoff/stage-3-done.md`

---

### Stage 4: iOS App — AI Screens + Senior Review + Security Scan

**Reads**: `docs/_handoff/stage-3-done.md`

**Assumes done**:
- iOS project foundation (tabs, design system, networking, push)
- Dashboard, Intake, Checkout screens working

**Sub-agents**: 2 parallel + 1 senior reviewer

- Agent 1 (ios-audio): FE-5 (Bio Scanner + Audio) + FE-10 (Cough Recommendation) + FE-11 (Sleep Assessment)
- Agent 2 (ios-food-metrics): FE-6 (Metrics Chart) + FE-7 (Alert Detail) + FE-8 (Rewards) + FE-12 (Food Camera) + FE-13 (Food Result)

**Context7 validation**:
- `resolve-library-id("AVFoundation")` → verify audio recording + camera capture
- `resolve-library-id("Swift Charts")` → verify BarMark, RuleMark patterns
- `resolve-library-id("CoreML")` → (reference only, Phase 2 on-device)
- Ghi kết quả vào SDD

**SDD**: Append to `docs/design/health360-ios.html`

**Key files to read**:
- `docs/presentation-health360-app.html` — Scanner, Metrics, Alert, Rewards, Checkout screens
- `ios/Health360/Services/APIClient.swift` — reuse networking layer from Stage 3
- `ios/Health360/Design/DesignSystem.swift` — reuse design tokens

**Deliverables**:
- `ios/Health360/Views/Scanner/ScannerView.swift` — mode toggle + camera + audio
- `ios/Health360/Views/Scanner/AudioWaveView.swift` — pulse animation
- `ios/Health360/Views/Scanner/FoodCameraView.swift` — AVFoundation capture
- `ios/Health360/Views/Scanner/FoodResultView.swift` — detected foods + nutrition + risk
- `ios/Health360/Views/Health/CoughRecommendationView.swift` — assessment + recommendations
- `ios/Health360/Views/Health/SleepAssessmentView.swift` — OSA survey + results
- `ios/Health360/Views/Metrics/MetricsView.swift` — 7-day bar chart
- `ios/Health360/Views/Alerts/AlertDetailView.swift` — clinical detail + O2O CTA
- `ios/Health360/Views/Rewards/RewardsView.swift` — coins + vouchers (UI only)
- `ios/Health360/Services/AudioRecorder.swift` — 5s WAV recording
- `ios/Health360/Services/CameraManager.swift` — photo capture + compression

**Senior Review** (bắt buộc — spawn riêng 1 sub-agent):
```
TASK: Senior review + patch + scope completeness + technology freshness
ROLE: Senior iOS architect / code reviewer
FILES TO REVIEW: All files in ios/Health360/ + backend/ changes across all stages
PLAN DOCUMENT: docs/plan.md
TASK DOCUMENT: docs/task.md
SDD: docs/design/health360-ios.html + docs/design/health360-backend.html
WORKING DIR: D:\AI\longchau-audio-sed-mvp
REQUIREMENTS:
1. Read PLAN + TASK documents — list every deliverable/exit criteria
2. Read all changed files across all stages
3. For each deliverable: verify code exists, is wired, has correct API integration
4. Identify bugs, edge cases, cross-platform issues, missing error handling
5. Fix each issue directly. Tag severity [P0]–[P3]
6. If scope gaps: implement missing pieces or report SCOPE GAP clearly
7. Context7: verify SwiftUI / FastAPI / Firebase SDK APIs are latest stable
8. Run build after fixes. If code changed → rerun review (loop until 0 P0–P1)
9. Report: scope checklist, tech freshness table, issues+severity, fixes, test results
DO NOT: Add features beyond plan scope, refactor beyond scope
```

**Security Scan** (bắt buộc trước commit):
- Scan toàn bộ diff cho secrets/PII/credentials
- Đặc biệt check: Firebase config files, API keys (OpenWeatherMap, Telegram Bot), .pem files
- Pattern-based + semantic-based detection
- [BLOCK] → không commit. [WARN] → confirm. [INFO] → proceed

**Exit gate**:
- [ ] All 13 iOS screens render correctly
- [ ] Audio recording → POST /api/analyze → display cough type result
- [ ] Food camera → POST /api/food-scan → display nutrition + risk alerts
- [ ] Metrics chart renders 7-day data with threshold line
- [ ] Sleep assessment flow: survey → submit → OSA risk displayed
- [ ] Xcode build succeeds with 0 warnings
- [ ] Senior review: 0 P0–P1 findings remaining
- [ ] Tech freshness: no deprecated APIs in new code
- [ ] Security scan: CLEAN (no [BLOCK])
- [ ] SDD complete

---

## ORCHESTRATOR INSTRUCTIONS

1. **Đọc lại plan.md + task.md** trước khi bắt đầu
2. Chạy Stage 1 bằng `subagent` tool (blocking mode, role: kiro_default)
   - Sub-agent prompt PHẢI include: "Dùng Context7 verify dependencies trước khi code"
3. Verify exit gate (chạy test/curl API endpoints) + scope completeness check
4. PASS → ghi handoff file → proceed Stage 2
5. FAIL → fix trong context, re-verify, KHÔNG skip
6. Lặp cho đến hết stages
7. Stage 4: senior review sub-agent + security scan trước commit
8. Final verify: check ALL 23 tasks từ task.md = ✅

## ERROR RECOVERY

- Sub-agent fail / partial output → đọc output, identify missing items, re-run stage với scope thu hẹp
- Context approaching limit → ghi progress vào handoff file, báo user resume point
- Test fail sau stage → fix trong stage đó trước khi proceed
- Context7 unavailable → proceed with best-known version, flag in SDD as "unverified"
- Senior review finds P0/P1 → fix immediately, rerun tests, rerun review (loop)
- ONNX model download fail → fallback mock response + flag

## FINAL EXIT CRITERIA

- [ ] Backend: 10 API endpoints live, all returning correct responses
- [ ] iOS: 13 screens implemented, dark mode, design matches HTML prototype
- [ ] Core loop: GPS + PM2.5 > 150 + ENT user → push notification < 15 phút
- [ ] Audio: Record 5s → cough detection + type classification → recommendation
- [ ] Food: Capture photo → YOLOv10 detect → nutrition + health risk alerts
- [ ] O2O: Alert → click → checkout → confirm → tracking UI
- [ ] SDD exists at `docs/design/health360-backend.html` + `docs/design/health360-ios.html`
- [ ] Context7 tech freshness verified
- [ ] Senior review verdict: APPROVED (0 P0–P1, scope 100%)
- [ ] Security scan: CLEAN
- [ ] No breaking changes to existing `/api/analyze` and `/api/recommendation`
