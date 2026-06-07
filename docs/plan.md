# AI HEALTH 360 — Production Execution Plan

> **Mục tiêu**: Validate User Behavior & Money Flow trong 4 tuần (Không cần AI phức tạp upfront)

---

## 📐 System Data Flow (4-Stage Pipeline)

```
[User Input/Intake] ──(JSON Profile)──► [Context Engine] ──(Enriched Data)──► [Rule Engine] ──(Trigger Match)──► [Alert & O2O Action]
```

---

## 🎯 Product Roadmap

### Phase 1: MVP (Month 1–2) — Core Engine & Fast Validation

| Component | Status | Chi tiết |
|-----------|--------|----------|
| User Intake | ✅ REAL | Form 3 câu hỏi nhanh onboard, lưu tags: `["ENT", "Gout", "Diabetes"]` |
| Context Engine | ✅ REAL | Gọi API OpenWeatherMap (Weather & PM2.5) theo GPS |
| Rule Engine | ✅ REAL | Code cứng if/else hoặc JSON Schema đơn giản |
| Alert System | ✅ REAL | Firebase Cloud Messaging (FCM) push notification |
| O2O Checkout | ✅ REAL | Deep link giỏ hàng đối tác (Long Châu) hoặc Landing Page 1-click |
| AI Audio (Cough/Snore/Breathe) | ✅ **REAL — ĐÃ CÓ** | YAMNet ONNX + Cough Type V2 (Dry/Wet) + Sleep OSA Screening + Recommendation Engine |
| AI Food Scanner | ✅ **REAL — Tích hợp FoodDetector** | YOLOv10 trained on VietFood67 (67 món Việt, mAP50=0.92) → Nhận diện + Nutrition breakdown |
| Gamification | ❌ FAKE | UI hardcode danh sách nhiệm vụ, chưa làm ví/đổi quà thật |

### Phase 2: Scale (Month 3–4) — Advanced AI & Engagement

- Audio AI Bio-signal Detection (on-device microphone)
- AI Food Scanner (image recognition thật)
- Gamification V1 (Task → Coin → Voucher exchange)

### Phase 3: Advanced (Month 5–6) — Clinical Precision Ecosystem

- Integrated Telehealth (video/audio consultation)
- Medical Ledger Interoperability (EMR/EHR sync)
- Offline Cache Engine (SQLite local)

---

---

## ✅ Existing Backend Capabilities (Tận dụng ngay cho iOS)

Source code `longchau-audio-sed-mvp` đã build sẵn các module AI thực sau:

### Audio Analysis Engine (Backend Python — FastAPI)

| Module | File | Chức năng | API Endpoint |
|--------|------|-----------|-------------|
| **YAMNet ONNX** | `yamnet_inference.py` | Phát hiện Ho, Thở, Khò khè, Ngáy realtime | `POST /api/analyze` |
| **Cough Type V2** | `cough_type_v2.py` | Phân loại Ho khan / Ho có đờm (MFCC + Dense) | `POST /api/analyze?mode=v2` |
| **Cough Recommendation** | `cough_recommendation.py` | Khuyến nghị chăm sóc + sản phẩm OTC theo loại ho | `POST /api/recommendation` |
| **Sleep/OSA Screening** | `sleep_recommendation.py` | Sàng lọc ngưng thở khi ngủ (STOP-Bang simplified) | *(cần expose API)* |
| **VAD Filter** | `vad_filter.py` | Lọc im lặng (FireRedVAD + RMS fallback) | *(internal)* |

### Detected Sound Classes

| Class ID | English | Tiếng Việt | Threshold |
|----------|---------|------------|-----------|
| 36 | Breathing | Thở | 0.65 |
| 37 | Wheeze | Thở khò khè | 0.65 |
| 38 | Snoring | Ngáy | 0.65 |
| 42 | Cough | Ho | 0.30 |

### Cough Type Classification Output

```json
{
  "cough_type": "dry",           // dry | wet
  "cough_type_vi": "Ho khan",
  "confidence": 0.892,
  "probabilities": {"dry": 0.892, "wet": 0.108}
}
```

### Recommendation Engine Output

- **Severity levels**: Nhẹ → Vừa → Nặng → Cần khám bác sĩ
- **Categories**: Home care, Food support, TPCN, OTC drugs, Consult pharmacist, See doctor
- **Product mapping**: Sản phẩm Long Châu theo loại ho + nhóm tuổi + triệu chứng

### Gợi ý tận dụng cho iOS App

1. **Không cần FAKE audio** — Backend đã có model thật, iOS chỉ cần ghi âm → gửi WAV → nhận kết quả
2. **Sleep OSA module** chưa expose API → cần thêm endpoint `POST /api/sleep-assessment`
3. **Frontend web** (`frontend/index.html` + `app.js`) đã có full UI flow — dùng làm reference cho iOS screens
4. **Models** (`yamnet.onnx` 16MB, `cough_type_weights.npz` 180KB) — có thể chạy on-device iOS nếu cần offline

---

## 🍲 Food Detection Integration (FoodDetector — VietFood67)

> Source: https://github.com/nvhnam/FoodDetector (MIT License, branch `v2`)
> Model: YOLOv10b trained on **VietFood67** dataset (67 classes, 33k images, mAP50 = 0.92)

### Architecture Flow

```
[User chụp ảnh mâm cơm]
         │
         ▼
[POST /api/food-scan (image)] ──► [YOLOv10 ONNX Inference]
         │                              │
         │                              ▼
         │                    Trả về nhãn: "pho_bo", "com_tam", "thit_kho"...
         │                              │
         ▼                              ▼
[User Profile (disease_tags)] ──► [Backend Core Service]
         │                              │
         │                    ┌─────────┴─────────┐
         │                    ▼                   ▼
         │          [Nutrition DB]      [Health Risk Engine]
         │          (Calories/Fat/      (Purine score cho Gút,
         │           Sugar/Salt)         Glycemic cho Tiểu đường,
         │                               Allergen warnings)
         ▼
[Response: Detected foods + Nutrition + Cảnh báo cá nhân hóa]
```

### 67 Vietnamese Food Classes (VietFood67)

Model nhận diện được: Phở, Bún bò Huế, Bún chả, Bánh mì, Cơm tấm, Bánh xèo, Bún riêu, Hủ tiếu, Lẩu, Thịt kho, Gỏi cuốn, Chả giò, Bún đậu, Mì Quảng, Cao lầu, Bánh cuốn, Bánh khọt, Bò kho, Xôi, và 48 loại khác.

### Nutrition Data (Built-in từ FoodDetector)

Mỗi class đã có sẵn data:
```json
{
  "name": "Pho (Vietnamese noodle soup)",
  "serving_type": "1 serving",
  "nutrition": { "Calories": 450, "Fat": 15, "Saturates": 5, "Sugar": 3, "Salt": 1.8 }
}
```

### Health Risk Mapping (CẦN BUILD THÊM — kết hợp User Profile)

| User Profile Tag | Food Risk Logic | Alert |
|-----------------|-----------------|-------|
| `Gout` | Purine score > threshold (hải sản, nội tạng, thịt đỏ) | ⚠️ "Món này giàu Purine — nguy cơ kích hoạt flare Gút" |
| `Diabetes_T2` | Glycemic load cao (cơm, xôi, bánh) | ⚠️ "Lượng đường/tinh bột cao — cần kiểm soát khẩu phần" |
| `Hypertension` | Salt > 1.5g/serving | ⚠️ "Hàm lượng muối vượt ngưỡng khuyến nghị" |
| `ENT` | Đồ lạnh, cay | ⚠️ "Thức ăn cay/lạnh có thể kích ứng đường hô hấp" |

### Purine Database (Bộ Y Tế — CẦN XÂY DỰNG)

```json
{
  "high_purine": ["Long heo", "Muc", "Tom", "Cua", "Oc", "Thit bo"],
  "moderate_purine": ["Thit heo", "Thit ga", "Ca", "Bun bo Hue"],
  "low_purine": ["Com", "Rau", "Dau hu", "Trung", "Bun", "Pho"]
}
```

### Backend Tasks (Food Detection)

| Task ID | Task | Sub-tasks | Sprint |
|---------|------|-----------|--------|
| **BE-8** | Food Detection API | • Tích hợp YOLOv10 ONNX model (export từ `.pt` sang `.onnx`) <br>• API `POST /api/food-scan` nhận image → trả detected foods + nutrition <br>• Batch detection (nhiều món trong 1 ảnh) | Sprint 1 |
| **BE-9** | Health Risk Engine | • Xây dựng Purine/Glycemic/Salt mapping per food class <br>• Cross-reference với `user.disease_tags` <br>• Trả cảnh báo cá nhân hóa kèm nutrition | Sprint 2 |
| **BE-10** | Bộ Y Tế Nutrition DB | • Mở rộng nutrition data với Purine score, Glycemic Index <br>• Source: Bảng thành phần dinh dưỡng Viện Dinh dưỡng VN <br>• JSON/SQLite format cho offline cache | Sprint 2 |

### iOS Tasks (Food Scanner)

| Task ID | Task | Sub-tasks | Sprint |
|---------|------|-----------|--------|
| **FE-12** | Food Scanner Camera | • AVFoundation camera viewfinder <br>• Bounding box overlay realtime (class label + confidence) <br>• Capture button → gửi `POST /api/food-scan` | Sprint 2 |
| **FE-13** | Food Result Screen | • Hiển thị detected foods (image crop + label) <br>• Nutrition breakdown per food (traffic light system: 🟢🟡🔴) <br>• Total meal nutrition summary <br>• Cảnh báo health risk theo profile user | Sprint 2 |

### Model Deployment Options

| Option | Pros | Cons | Recommend |
|--------|------|------|-----------|
| **Server-side** (ONNX Runtime) | Dễ update model, nhẹ cho client | Cần internet, latency | ✅ MVP |
| **On-device** (Core ML) | Offline, nhanh | Model 50MB+, khó update | Phase 2 |
| **Hybrid** | Offline fallback + server khi có mạng | Complex logic | Phase 3 |

---

## 🛠️ Task Breakdown (Engineer-Ready)

### Backend (Node.js / Go)

| Task ID | Task | Sub-tasks | Sprint |
|---------|------|-----------|--------|
| **BE-1** | User Profile & Intake API | • DB Schema: `User(Id, Name, DeviceToken, Lat, Long)` <br>• API `POST /api/v1/user/intake` lưu `disease_tags[]` | Sprint 1 |
| **BE-2** | Context Aggregator Service | • Cronjob 30 phút lấy location users active <br>• Tích hợp OpenWeatherMap API fetch AQI + PM2.5 | Sprint 1 |
| **BE-3** | Hardcoded Rule Engine | • Hàm `evaluateRules(userProfile, contextData)` <br>• Rule: ENT + PM2.5>150 → trigger alert template | Sprint 1 |
| **BE-4** | Alert Dispatcher | • Tích hợp FCM gửi push notification <br>• Template management cho alert messages | Sprint 1 |
| **BE-5** | Mock AI Endpoints | • API `POST /api/v1/ai/food-scan` nhận ảnh → push Telegram/Discord cho Ops <br>• Trả Mock Response sau 2 giây | Sprint 1 |
| **BE-6** | O2O Checkout API | • Landing page 1-click purchase <br>• Analytics tracking (click, conversion) | Sprint 2 |
| **BE-7** | Expose Sleep Assessment API | • `POST /api/sleep-assessment` endpoint <br>• Wire `sleep_recommendation.py` vào app.py <br>• Return OSA risk + recommendations | Sprint 1 |

### Mobile (iOS — Swift/SwiftUI)

| Task ID | Task | Sub-tasks | Sprint |
|---------|------|-----------|--------|
| **FE-1** | Core App Layout & Permissions | • Request Background Location + Push Notification <br>• Tab bar navigation (5 tabs) <br>• Dark mode theme system | Sprint 1 |
| **FE-2** | Intake Wizard Screen | • Checkbox bệnh nền (Gút, ENT, Tiểu đường, Huyết áp) <br>• Form nhập chỉ số sinh hiệu <br>• Triệu chứng lâm sàng checklist | Sprint 1 |
| **FE-3** | Dashboard (Home) Screen | • Chỉ số sinh học tổng hợp (circular gauge) <br>• Context card (Weather, Humidity, PM2.5) <br>• Alert card với border-left color coding <br>• Daily health task checklist | Sprint 1 |
| **FE-4** | Notification & Deep-linking | • Firebase SDK nhận Push khi app background <br>• Click notification → điều hướng trang sản phẩm O2O | Sprint 1 |
| **FE-5** | Bio Scanner Screen (REAL Audio) | • Camera Viewfinder với overlay animation <br>• Toggle: Dinh Dưỡng / Hô Hấp <br>• Audio recording 5s → gửi `POST /api/analyze?mode=v2` <br>• Hiển thị kết quả: loại ho, confidence, waveform <br>• Trigger recommendation flow nếu phát hiện ho | Sprint 2 |
| **FE-6** | Metrics/Trend Screen | • Bar chart 7 ngày (Uric, Hô hấp, Đường, HA) <br>• Segment control switch metric type <br>• Threshold line (dashed red) | Sprint 2 |
| **FE-7** | Alert Detail Screen | • 3-Layer architecture display <br>• O2O recommendation cards <br>• CTA: Tư vấn bác sĩ khẩn cấp | Sprint 2 |
| **FE-8** | Rewards Center Screen | • Coin balance display <br>• Voucher list với giá xu <br>• Đổi quà action (UI only, fake backend) | Sprint 2 |
| **FE-9** | Express Checkout Screen | • Product card từ đề xuất O2O <br>• GPS delivery location <br>• Confirm button → Tracking UI (shipper animation) | Sprint 2 |
| **FE-10** | Cough Recommendation Screen | • Hiển thị phân loại (severity, type) <br>• Khuyến nghị theo categories (home care → OTC → bác sĩ) <br>• Product cards Long Châu tích hợp <br>• Red flags warning | Sprint 2 |
| **FE-11** | Sleep Assessment Screen | • Khảo sát OSA (snoring freq, sleepiness, body type) <br>• Hiển thị risk score + recommendations <br>• Trigger khi phát hiện Snoring/Breathing bất thường | Sprint 2 |

---

## 📱 iOS Build Suggestions (Dựa trên HTML Design)

### Recommended Tech Stack

| Layer | Technology | Lý do |
|-------|-----------|-------|
| **UI Framework** | SwiftUI | Dark mode first, declarative, rapid prototyping |
| **Architecture** | MVVM + Coordinator | Clean separation, testable |
| **Navigation** | TabView + NavigationStack | 5 tabs như design |
| **Networking** | URLSession + async/await | Native, no deps |
| **Push** | Firebase Cloud Messaging | Cross-platform, free tier |
| **Location** | CoreLocation | Background GPS tracking |
| **Camera** | AVFoundation | Custom viewfinder overlay |
| **Charts** | Swift Charts (iOS 16+) | Native bar charts |
| **Local Storage** | SwiftData hoặc Core Data | Offline cache |
| **Analytics** | Firebase Analytics | Track CTR, conversion |

### Design System (Từ HTML → SwiftUI)

```swift
// Color Tokens (từ presentation-health360-app.html)
extension Color {
    static let bg = Color(hex: "0f172a")
    static let card = Color(hex: "1e293b")
    static let cardHover = Color(hex: "263548")
    static let textPrimary = Color(hex: "f1f5f9")
    static let muted = Color(hex: "94a3b8")
    static let border = Color(hex: "334155")
    
    // Accents
    static let accentBlue = Color(hex: "38bdf8")    // Context & Audio
    static let accentTeal = Color(hex: "14b8a6")    // Safe status
    static let accentOrange = Color(hex: "f97316")  // Warning & Gout
    static let accentPurple = Color(hex: "a78bfa")  // Respiratory
    static let accentRed = Color(hex: "ef4444")     // Critical
}
```

### Screen Architecture Map

```
TabView (5 tabs)
├── Tab 1: HomeView (Dashboard)
│   ├── HeaderView (avatar, greeting, notifications)
│   ├── BiometricGaugeView (circular Uric display)
│   ├── ContextCardView (temp, humidity, PM2.5)
│   ├── AlertBannerView (ENT Protocol warning)
│   ├── SymptomsTagView (flex wrap badges)
│   └── DailyTasksView (checklist + coins)
│
├── Tab 2: MetricsView (Trend Charts)
│   ├── SegmentedControl (Uric/Hô hấp/Đường/HA)
│   └── BarChartView (7-day with threshold line)
│
├── Tab 3 (FAB): ScannerView
│   ├── CameraViewfinderView (overlay + bbox)
│   ├── AudioWaveView (pulse animation)
│   └── ModeToggle (Dinh dưỡng / Hô hấp)
│
├── Tab 4: RewardsView
│   ├── CoinBalanceView
│   └── VoucherListView (cards with exchange button)
│
└── Tab 5: ProfileView (Intake/Settings)
    ├── DiseaseTagsForm
    ├── SymptomsChecklist
    ├── VitalSignsForm
    └── PermissionsManager
```

### Key UI Components to Build

| Component | Từ Design | Priority |
|-----------|-----------|----------|
| `CircularGauge` | Vòng tròn chỉ số Uric 425 | P0 |
| `AlertCard` | Card viền trái đỏ/cam + badge | P0 |
| `ContextTile` | 3 ô nhỏ (Temp/Humidity/PM2.5) | P0 |
| `BadgeTag` | Pill badges nhiều màu | P0 |
| `TaskCheckRow` | Checkbox + text + coins reward | P1 |
| `BarChart7Day` | 7 cột + dashed threshold line | P1 |
| `WaveformView` | Audio pulse animation 5 bars | P1 |
| `CameraOverlay` | Bounding box + label + confidence | P1 |
| `ProductCard` | Hỏa tốc item + price + CTA | P2 |
| `TrackingMap` | Placeholder map shipper | P2 |

---

## 🏃 Sprint Roadmap (2-Week Sprints)

### Sprint 1 (Tuần 1–2): Core Loop Pipeline

**Mục tiêu**: Hệ thống tự động nhận diện User nguy cơ → gửi Push Notification đúng context.

**Backend:**
- [ ] BE-1: DB Schema + Intake API
- [ ] BE-2: Context Aggregator (OpenWeatherMap integration)
- [ ] BE-3: Rule Engine (hardcoded if/else)
- [ ] BE-4: FCM Push setup
- [ ] BE-5: Mock AI endpoints

**Mobile iOS:**
- [ ] FE-1: Project setup, permissions, tab navigation
- [ ] FE-2: Intake Wizard (onboarding form)
- [ ] FE-3: Dashboard Home screen
- [ ] FE-4: Push notification receiver + deep link

**Milestone 1** ✅: Test nội bộ — GPS vào vùng PM2.5>150 → nhận Push trong 15 phút.

---

### Sprint 2 (Tuần 3–4): Kích hoạt dòng tiền

**Mục tiêu**: Đo lường CTR và Conversion Rate O2O.

**Backend:**
- [ ] BE-6: O2O Checkout API + Landing page
- [ ] Analytics integration (Firebase/Mixpanel)

**Mobile iOS:**
- [ ] FE-5: Bio Scanner screen (camera + audio wave fake)
- [ ] FE-6: Metrics/Trend chart screen
- [ ] FE-7: Alert Detail screen
- [ ] FE-8: Rewards Center (UI only)
- [ ] FE-9: Express Checkout + Tracking

**Milestone 2** ✅: Launch Beta 200–500 users (tệp viêm mũi dị ứng/hô hấp nhạy cảm).

---

## 📊 Campaign Validation (Quick Win — Tuần 4)

### Kịch bản thực tế

```
User X ở Quận 7 (Sài Gòn) → PM2.5 = 160 μg/m³
→ Profile có tag "ENT" (Viêm mũi/xoang)
→ Push: "PM2.5 mức nguy hại (160). Nguy cơ flare viêm mũi 85% trong 24h."
→ CTA: [Mua ngay bộ rửa mũi & Khẩu trang - Giao 15p]
→ Click → Giỏ hàng Long Châu có sẵn combo
```

### Success Metrics

| Metric | Formula | Target |
|--------|---------|--------|
| **CTR Alert** | Clicks / Total push sent | > 15% |
| **Conversion Rate** | Orders / Product page views | > 3% |
| **Repeat Usage** | Users quay lại scan/check lần 2 / Total onboard | Track |

---

## ⚠️ Risks & Mitigation

| Risk | Impact | Mitigation |
|------|--------|-----------|
| AI Latency / False Accuracy | User mất tin tưởng | Fallback heuristic: AI confidence < 75% → dùng threshold rules |
| Gamification Token Exploit | Lỗ kinh tế | Hard limit 150 coins/day + separate transaction ledger |
| Misdiagnosis Liability | Pháp lý | Classify app = "General Wellness Tool", Layer 3 HITL bắt buộc |
| PM2.5 API downtime | Alert không gửi | Cache last-known value + fallback 2nd provider |

---

## 👥 Team & Responsibility

| Role | Ownership |
|------|-----------|
| PM | User journeys, intake flow, gamification economics |
| Medical Consultant | Verify Rule Engine thresholds |
| Mobile Engineer (iOS) | SwiftUI screens, camera/audio wrappers, SQLite |
| Backend Engineer | Context API, Rule Engine, FCM, O2O webhooks |
| Ops / Partnership | Nhà thuốc onboarding, delivery logistics |

---

## 🔗 Dependencies

| Dependency | Blocks |
|-----------|--------|
| Medical Lead finalize clinical data model | Rule Engine logic |
| Partner pharmacy API catalog + webhook auth | O2O Instant Dispatch |
| iOS Camera/Location/Notification permissions approved | Scanner & Alert features |
