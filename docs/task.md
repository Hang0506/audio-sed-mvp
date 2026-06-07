# AI HEALTH 360 — Task Board

> Tổng: **23 tasks** | Sprint 1: 12 tasks | Sprint 2: 11 tasks
> Status: ⬜ Todo | 🟡 In Progress | ✅ Done | 🚫 Blocked

---

## Sprint 1 (Tuần 1–2): Core Loop Pipeline

**Goal**: User có nguy cơ → nhận Push Notification đúng context trong 15 phút.

---

### 🔧 Backend

#### BE-1: User Profile & Intake API
- **Priority**: P0 (blocks FE-2, FE-3, BE-3)
- **Assignee**: Backend Engineer
- **Status**: ⬜
- **Sub-tasks**:
  - [ ] Thiết kế DB Schema: `User(id, name, device_token, lat, long, disease_tags[], created_at)`
  - [ ] API `POST /api/v1/user/intake` — nhận và lưu `disease_tags[]`
  - [ ] API `GET /api/v1/user/profile` — trả profile + tags
  - [ ] Validation: tags chỉ cho phép enum `["ENT", "Gout", "Diabetes_T2", "Hypertension"]`
- **Acceptance**: Postman call intake → DB lưu đúng → GET trả đúng profile

---

#### BE-2: Context Aggregator Service
- **Priority**: P0 (blocks BE-3)
- **Assignee**: Backend Engineer
- **Status**: ⬜
- **Sub-tasks**:
  - [ ] Cronjob mỗi 30 phút: lấy danh sách location users active
  - [ ] Tích hợp OpenWeatherMap Air Pollution API → fetch AQI + PM2.5 theo `(lat, long)`
  - [ ] Cache kết quả vào DB/Redis (tránh rate limit)
  - [ ] API `GET /api/v1/context/{user_id}` — trả weather + PM2.5 hiện tại
- **Acceptance**: Gọi API với tọa độ HCM → trả PM2.5 thực tế

---

#### BE-3: Hardcoded Rule Engine
- **Priority**: P0 (blocks BE-4)
- **Assignee**: Backend Engineer
- **Status**: ⬜
- **Dependencies**: BE-1, BE-2
- **Sub-tasks**:
  - [ ] Hàm `evaluateRules(userProfile, contextData)` → return `{triggerAlert, templateId}`
  - [ ] Rule 1: `ENT + PM2.5 > 150` → trigger `ALERT_ENT_PM25`
  - [ ] Rule 2: `Gout + humidity > 85%` → trigger `ALERT_GOUT_HUMIDITY`
  - [ ] Rule 3: `Diabetes_T2 + temperature > 35°C` → trigger `ALERT_DIABETES_HEAT`
  - [ ] Rule store: JSON config file (dễ thêm rule không cần deploy)
- **Acceptance**: Unit test pass 3 rules trên

---

#### BE-4: Alert Dispatcher (FCM)
- **Priority**: P0 (blocks FE-4)
- **Assignee**: Backend Engineer
- **Status**: ⬜
- **Dependencies**: BE-3
- **Sub-tasks**:
  - [ ] Setup Firebase project + Service Account
  - [ ] Tích hợp FCM Admin SDK (Python `firebase-admin`)
  - [ ] Hàm `sendAlert(userId, templateId)` → push notification với title/body/deeplink
  - [ ] Alert templates: 3 templates cho 3 rules
  - [ ] Logging: ghi lại mọi alert đã gửi (timestamp, userId, templateId, success/fail)
- **Acceptance**: Trigger rule → nhận push trên device test trong < 30s

---

#### BE-5: Mock AI Endpoints (Food Scan qua Ops)
- **Priority**: P1
- **Assignee**: Backend Engineer
- **Status**: ⬜
- **Sub-tasks**:
  - [ ] API `POST /api/v1/ai/food-scan` — nhận `multipart/form-data` (image)
  - [ ] Push ảnh qua Telegram Bot API (hoặc Discord webhook) cho Ops team
  - [ ] Ops bấm reply với label → webhook callback update kết quả
  - [ ] Trả Mock Response sau 2–5 giây nếu Ops chưa reply (default template)
- **Acceptance**: Upload ảnh → Ops nhận được trên Telegram → reply → app nhận kết quả

---

#### BE-7: Expose Sleep Assessment API
- **Priority**: P1
- **Assignee**: Backend Engineer
- **Status**: ⬜
- **Sub-tasks**:
  - [ ] Thêm endpoint `POST /api/sleep-assessment` vào `app.py`
  - [ ] Wire `SleepAssessment` dataclass + `classify_and_recommend_sleep()` từ `sleep_recommendation.py`
  - [ ] Input: `{snoring_freq, daytime_sleepiness, apnea_observed, body_type, sleep_symptoms[]}`
  - [ ] Output: `{classification, recommendations[], warnings[], should_see_doctor}`
- **Acceptance**: POST với data → trả OSA risk score + recommendations

---

#### BE-8: Food Detection API (YOLOv10)
- **Priority**: P1
- **Assignee**: Backend/AI Engineer
- **Status**: ⬜
- **Sub-tasks**:
  - [ ] Export YOLOv10 model từ `.pt` → `.onnx` (hoặc dùng trực tiếp ONNX có sẵn trong FoodDetector repo)
  - [ ] Copy `class_names.py` (67 classes + nutrition data) vào project
  - [ ] API `POST /api/food-scan` — nhận image → ONNX inference → trả detected foods + nutrition
  - [ ] Response format: `{foods: [{name, confidence, bbox, nutrition}], total_nutrition}`
  - [ ] Timeout: inference < 3 giây trên CPU
- **Acceptance**: Upload ảnh phở → trả `"Pho"` + calories 450

---

### 📱 Mobile iOS

#### FE-1: Core App Layout & Permissions
- **Priority**: P0 (blocks tất cả FE khác)
- **Assignee**: Mobile Engineer
- **Status**: ⬜
- **Sub-tasks**:
  - [ ] Tạo Xcode project (SwiftUI, iOS 16+)
  - [ ] Setup Design System: colors, fonts, spacing tokens (từ HTML design)
  - [ ] TabView 5 tabs: Home, Metrics, Scanner (FAB), Rewards, Profile
  - [ ] Request permissions: Location (always), Push Notification, Camera, Microphone
  - [ ] Dark mode theme (mặc định dark)
  - [ ] Networking layer: `APIClient` class với base URL config
- **Acceptance**: App launch → 5 tabs hiển thị → permissions dialog xuất hiện

---

#### FE-2: Intake Wizard Screen
- **Priority**: P0 (blocks BE-1 integration)
- **Assignee**: Mobile Engineer
- **Status**: ⬜
- **Sub-tasks**:
  - [ ] UI: Checkbox list bệnh nền (Gút, Viêm xoang, Tiểu đường T2, Cao huyết áp)
  - [ ] UI: Triệu chứng lâm sàng grid (2 columns checkboxes)
  - [ ] UI: Form nhập chỉ số (Huyết áp, Đường huyết, Axit Uric, Cân nặng/Chiều cao)
  - [ ] UI: Textarea mô tả triệu chứng khác
  - [ ] Call `POST /api/v1/user/intake` khi submit
  - [ ] Lưu profile local (UserDefaults / SwiftData) cho offline
- **Acceptance**: Chọn tags → submit → server lưu → app hiển thị profile đúng

---

#### FE-3: Dashboard (Home) Screen
- **Priority**: P0
- **Assignee**: Mobile Engineer
- **Status**: ⬜
- **Dependencies**: FE-1
- **Sub-tasks**:
  - [ ] Header: Avatar + "Chào [Tên]" + notification bell
  - [ ] `CircularGauge`: Vòng tròn hiển thị Uric (value + unit + status color)
  - [ ] `ContextCard`: 3 tiles — Nhiệt độ, Độ ẩm, PM2.5 (với border đỏ nếu > 150)
  - [ ] `AlertBanner`: Card viền trái đỏ + badge + nội dung cảnh báo
  - [ ] `SymptomsTag`: Flex wrap badges nhiều màu (từ profile)
  - [ ] `DailyTasks`: Checklist (checkbox + text + "+XX xu")
  - [ ] Pull-to-refresh gọi `GET /api/v1/context/{userId}`
- **Acceptance**: Dashboard hiển thị đúng data từ API, PM2.5 card đỏ khi > 150

---

#### FE-4: Notification Receiver & Deep-linking
- **Priority**: P0
- **Assignee**: Mobile Engineer
- **Status**: ⬜
- **Dependencies**: BE-4
- **Sub-tasks**:
  - [ ] Tích hợp Firebase SDK (SPM: `firebase-ios-sdk`)
  - [ ] Register device token → gửi về `POST /api/v1/user/device-token`
  - [ ] Handle push foreground + background
  - [ ] Deep-link: click notification → navigate tới O2O product page hoặc Alert Detail
  - [ ] Badge count trên app icon
- **Acceptance**: Backend trigger alert → device nhận push < 30s → click → đúng screen

---

## Sprint 2 (Tuần 3–4): AI Features + Dòng Tiền

**Goal**: CTR > 15%, Conversion Rate > 3%.

---

### 🔧 Backend

#### BE-6: O2O Checkout API
- **Priority**: P0 (revenue validation)
- **Assignee**: Backend Engineer
- **Status**: ⬜
- **Sub-tasks**:
  - [ ] Landing page 1-click purchase (embedded webview hoặc deep link Long Châu)
  - [ ] API `POST /api/v1/order/create` — lưu order intent (userId, productId, timestamp)
  - [ ] Analytics events: `page_view`, `add_to_cart`, `purchase_complete`
  - [ ] Firebase Analytics / Mixpanel integration
- **Acceptance**: User click CTA → landing page → track conversion event

---

#### BE-9: Health Risk Engine
- **Priority**: P1
- **Assignee**: Backend/AI Engineer
- **Status**: ⬜
- **Dependencies**: BE-8, BE-1
- **Sub-tasks**:
  - [ ] Purine mapping: classify 67 food classes → `high/moderate/low` purine
  - [ ] Glycemic mapping: classify foods → `high/moderate/low` GI
  - [ ] Salt threshold: flag foods with Salt > 1.5g/serving
  - [ ] Hàm `assessHealthRisk(detectedFoods, userProfile)` → warnings[]
  - [ ] Response kèm `risk_alerts[]` trong food-scan result
- **Acceptance**: User Gout + ảnh hải sản → trả alert "Purine cao, nguy cơ flare"

---

#### BE-10: Bộ Y Tế Nutrition DB
- **Priority**: P2
- **Assignee**: Backend Engineer + Medical Consultant
- **Status**: ⬜
- **Sub-tasks**:
  - [ ] Thu thập data Viện Dinh dưỡng VN (Purine index, Glycemic Index per food)
  - [ ] Merge với FoodDetector nutrition data (67 classes)
  - [ ] Format: JSON file hoặc SQLite cho mobile offline
  - [ ] API `GET /api/v1/nutrition/{food_class}` — trả full nutrition + risk info
- **Acceptance**: Query "pho" → trả Calories + Purine level + GI

---

### 📱 Mobile iOS

#### FE-5: Bio Scanner Screen (REAL Audio)
- **Priority**: P0
- **Assignee**: Mobile Engineer
- **Status**: ⬜
- **Sub-tasks**:
  - [ ] Camera Viewfinder (AVFoundation) với overlay frame
  - [ ] Mode Toggle: "🥗 Dinh Dưỡng" / "🎙️ Hô Hấp" (SegmentedControl)
  - [ ] **Mode Hô Hấp**: Record 5s audio → convert WAV → `POST /api/analyze?mode=v2`
  - [ ] Audio wave animation (5 bars pulse) khi recording
  - [ ] Hiển thị kết quả: Ho khan/đờm, confidence %, events timeline
  - [ ] Nếu `has_cough=true` → navigate sang FE-10 (Recommendation)
  - [ ] Nếu `has_snoring=true` → navigate sang FE-11 (Sleep Assessment)
  - [ ] **Mode Dinh Dưỡng**: Capture photo → `POST /api/food-scan` → FE-13
- **Acceptance**: Record 5s ho → hiển thị "Ho khan 89%" → navigate recommendation

---

#### FE-6: Metrics/Trend Screen
- **Priority**: P1
- **Assignee**: Mobile Engineer
- **Status**: ⬜
- **Sub-tasks**:
  - [ ] SegmentedControl: Axit Uric / Hô Hấp / Tiểu Đường / Huyết Áp
  - [ ] Swift Charts: Bar chart 7 ngày gần nhất
  - [ ] Dashed red line: threshold ngưỡng nguy hiểm
  - [ ] Interactive: tap bar → hiển thị value + date
  - [ ] Data source: local storage (SwiftData) + sync từ server
- **Acceptance**: Hiển thị chart 7 ngày, dashed line đúng threshold

---

#### FE-7: Alert Detail Screen
- **Priority**: P1
- **Assignee**: Mobile Engineer
- **Status**: ⬜
- **Sub-tasks**:
  - [ ] Header gradient đỏ + tiêu đề lâm sàng
  - [ ] 3-Layer display (AI Classifier / Rule Engine / Human validation)
  - [ ] Nội dung chi tiết cảnh báo (markdown-like rendering)
  - [ ] O2O recommendation cards (product + "Giao hỏa tốc" button)
  - [ ] CTA: "🚨 Kích hoạt tư vấn bác sĩ khẩn cấp"
- **Acceptance**: Navigate từ push → hiển thị full alert + product cards

---

#### FE-8: Rewards Center Screen
- **Priority**: P2
- **Assignee**: Mobile Engineer
- **Status**: ⬜
- **Sub-tasks**:
  - [ ] Coin balance header (gradient card)
  - [ ] Membership badge display
  - [ ] Voucher list: cards với tên + giá xu + "ĐỔI QUÀ" button
  - [ ] State: đủ xu → teal button | thiếu xu → red "THIẾU" badge
  - [ ] UI only (no real backend exchange) — track tap events
- **Acceptance**: Hiển thị 750 coins, 2 voucher cards, tap "ĐỔI QUÀ" → alert confirm

---

#### FE-9: Express Checkout Screen
- **Priority**: P0 (revenue)
- **Assignee**: Mobile Engineer
- **Status**: ⬜
- **Sub-tasks**:
  - [ ] Product card: tên + giá + quantity + nhà thuốc Long Châu
  - [ ] GPS delivery location (CoreLocation → display address)
  - [ ] CTA button: "XÁC NHẬN GIAO HỎA TỐC (15 PHÚT)"
  - [ ] After confirm: Tracking card (shipper status + ETA)
  - [ ] Analytics: track `checkout_view`, `checkout_confirm`
- **Acceptance**: Click confirm → show tracking UI → analytics event fired

---

#### FE-10: Cough Recommendation Screen
- **Priority**: P1
- **Assignee**: Mobile Engineer
- **Status**: ⬜
- **Dependencies**: FE-5
- **Sub-tasks**:
  - [ ] Assessment form: cough type, duration, subject group, red flags
  - [ ] Call `POST /api/recommendation` với form data + audio results
  - [ ] Display: severity badge + recommendation categories (expandable cards)
  - [ ] Product suggestions (OTC từ Long Châu) per category
  - [ ] Red flag warnings → "Cần khám bác sĩ ngay" prominent CTA
- **Acceptance**: Submit assessment → hiển thị recommendations + products

---

#### FE-11: Sleep Assessment Screen
- **Priority**: P1
- **Assignee**: Mobile Engineer
- **Status**: ⬜
- **Dependencies**: BE-7, FE-5
- **Sub-tasks**:
  - [ ] Survey form: snoring frequency, daytime sleepiness, apnea observed, body type
  - [ ] Symptoms checklist (dry mouth, headache, concentration...)
  - [ ] Call `POST /api/sleep-assessment`
  - [ ] Display: OSA risk score (Low/Moderate/High) + color
  - [ ] Recommendations by category (see doctor, lifestyle, sleep hygiene, products)
- **Acceptance**: Submit → hiển thị "Nguy cơ TRUNG BÌNH" + 4 categories recommendations

---

#### FE-12: Food Scanner Camera
- **Priority**: P1
- **Assignee**: Mobile Engineer
- **Status**: ⬜
- **Dependencies**: BE-8
- **Sub-tasks**:
  - [ ] AVFoundation camera session (rear camera)
  - [ ] Capture button (like design — circle with white fill)
  - [ ] Capture → compress JPEG → `POST /api/food-scan`
  - [ ] Loading overlay during inference (< 3s)
  - [ ] Navigate to FE-13 with results
- **Acceptance**: Chụp ảnh phở → loading → navigate result screen

---

#### FE-13: Food Result Screen
- **Priority**: P1
- **Assignee**: Mobile Engineer
- **Status**: ⬜
- **Dependencies**: FE-12, BE-8, BE-9
- **Sub-tasks**:
  - [ ] Detected foods list: crop image + label + confidence %
  - [ ] Per-food nutrition card: Calories/Fat/Saturates/Sugar/Salt
  - [ ] Traffic light badges (🟢🟡🔴) per nutrient
  - [ ] Total meal nutrition summary (sum all detected)
  - [ ] Health risk alerts (if any) — based on user profile
  - [ ] CTA: "Mua thực phẩm thay thế tốt hơn" → O2O
- **Acceptance**: 3 foods detected → hiển thị nutrition + 1 alert cho user Gout

---

## 📋 Summary Table

| ID | Task | Sprint | Priority | Depends On | Status |
|----|------|--------|----------|------------|--------|
| BE-1 | User Profile & Intake API | 1 | P0 | — | ⬜ |
| BE-2 | Context Aggregator | 1 | P0 | — | ⬜ |
| BE-3 | Rule Engine | 1 | P0 | BE-1, BE-2 | ⬜ |
| BE-4 | Alert Dispatcher (FCM) | 1 | P0 | BE-3 | ⬜ |
| BE-5 | Mock AI (Telegram Ops) | 1 | P1 | — | ⬜ |
| BE-7 | Sleep Assessment API | 1 | P1 | — | ⬜ |
| BE-8 | Food Detection API | 1 | P1 | — | ⬜ |
| BE-6 | O2O Checkout API | 2 | P0 | — | ⬜ |
| BE-9 | Health Risk Engine | 2 | P1 | BE-8, BE-1 | ⬜ |
| BE-10 | Bộ Y Tế Nutrition DB | 2 | P2 | BE-8 | ⬜ |
| FE-1 | Core Layout & Permissions | 1 | P0 | — | ⬜ |
| FE-2 | Intake Wizard | 1 | P0 | FE-1 | ⬜ |
| FE-3 | Dashboard Home | 1 | P0 | FE-1 | ⬜ |
| FE-4 | Notification & Deep-link | 1 | P0 | BE-4, FE-1 | ⬜ |
| FE-5 | Bio Scanner (Audio REAL) | 2 | P0 | FE-1 | ⬜ |
| FE-6 | Metrics/Trend Chart | 2 | P1 | FE-1 | ⬜ |
| FE-7 | Alert Detail | 2 | P1 | FE-4 | ⬜ |
| FE-8 | Rewards Center | 2 | P2 | FE-1 | ⬜ |
| FE-9 | Express Checkout | 2 | P0 | BE-6, FE-1 | ⬜ |
| FE-10 | Cough Recommendation | 2 | P1 | FE-5 | ⬜ |
| FE-11 | Sleep Assessment | 2 | P1 | BE-7, FE-5 | ⬜ |
| FE-12 | Food Scanner Camera | 2 | P1 | BE-8, FE-1 | ⬜ |
| FE-13 | Food Result Screen | 2 | P1 | FE-12, BE-9 | ⬜ |

---

## 🔀 Dependency Graph

```
Sprint 1:
  BE-1 ──┐
  BE-2 ──┼──► BE-3 ──► BE-4 ──► FE-4
         │
  FE-1 ──┼──► FE-2
         ├──► FE-3
         └──► FE-4

  BE-7 (independent)
  BE-8 (independent)
  BE-5 (independent)

Sprint 2:
  BE-8 ──► BE-9 ──► FE-13
  BE-8 ──► FE-12 ──► FE-13
  BE-6 ──► FE-9
  FE-5 ──► FE-10
  FE-5 ──► FE-11
  BE-7 ──► FE-11
```

---

## ✅ Milestones

| # | Milestone | Khi nào | Criteria |
|---|-----------|---------|----------|
| M1 | Core Loop Works | End Sprint 1 | GPS vùng PM2.5>150 → push notification < 15 phút |
| M2 | AI Audio Live | Mid Sprint 2 | Record ho → phân loại đúng → recommendation hiển thị |
| M3 | Food Scan Live | Mid Sprint 2 | Chụp ảnh phở → detect + nutrition + alert (nếu Gout) |
| M4 | Beta Launch | End Sprint 2 | 200–500 users, track CTR > 15%, CR > 3% |
