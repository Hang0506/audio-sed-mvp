# AI Health 360 v6 — Execution Prompt

> Auto-generated from plan: `docs/Plan.html` (v6 — Aligned with App Design)
> Stages: 3 | Total deliverables: 14 FE tasks + 4 INFRA tasks

## TASK
Rewrite iOS SwiftUI app to match the 7-screen ENT-focused design in `presentation-health360-app.html`. Replace old generic health dashboard with symptom-driven feature-gated daily loop (Morning Weather → Noon Camera → Night Audio → Weekly Review → Marketplace).

## WORKING DIR
`D:\AI\longchau-audio-sed-mvp`

## CONTEXT
- Existing backend FastAPI at `backend/` already has: audio analyze, cough type, sleep recommendation, food scan, intake, context APIs
- Existing iOS skeleton at `ios/Health360/` has: DesignSystem, APIClient, AudioRecorder, CameraManager — all reusable
- Old views (IntakeWizardView, DashboardView, etc.) use wrong data model (generic diseases) — must be rewritten for ENT symptom_ids
- Design tokens in `DesignSystem.swift` already match the presentation CSS vars (blue, teal, orange, purple, red)
- App is dark-mode only, iOS 16+ minimum

## CONSTRAINTS
- SwiftUI only (no UIKit except camera/audio bridging)
- MVVM + Combine pattern
- Reuse existing `APIClient.swift` and `DesignSystem.swift`
- Gamification coins are LOCAL only (`@AppStorage`) — no backend wallet
- Feature gate: screens 3-5 conditionally render widgets based on `symptom_ids` from intake
- No Firebase dependency for MVP (remove from App entry point) — simplify to pure SwiftUI
- Keep backend unchanged — only add new endpoints if missing

## EXECUTION — 3-STAGE CHAIN

> ⚠️ Orchestrator prompt. Chạy từng stage tuần tự. Mỗi stage = 1 sub-agent DAG blocking.

---

### Stage 1: Foundation + Onboarding (Screens 1–2)
**Sub-agents**: 2 parallel
- Agent 1 (infra): Setup project structure, models, services, feature gate
- Agent 2 (ui): Intake survey screen + loading/analysis screen

**Deliverables**:
- `INFRA-01`: Clean project setup — remove Firebase, simplify App entry. SPM: just Alamofire (or keep URLSession-based APIClient as-is)
- `INFRA-02`: `CoinManager` — `@AppStorage("masterCoins")` singleton, `addCoins()` with animation trigger
- `INFRA-03`: `FeatureGateService` — reads `Set<String> symptomIDs` → computes `enabledFeatures: [.weather, .camera, .audio]`
- `FE-01`: `ENTSurveyView` — Multi-select checkbox cards grouped 👃 Mũi / 🗣️👂 Họng-Tai. Each option shows symptom + hardware trigger description. Blue/purple border when selected. State: `@State var selectedSymptomIDs: Set<String>`
- `FE-02`: `AnalysisLoadingView` — Spinner + sequential text animation ("Khởi tạo cảm biến..." → "Đồng bộ phần cứng...") → auto-navigate to Home after 2.5s

**Models to create/update**:
```swift
// Models/SymptomOption.swift
struct SymptomOption: Identifiable {
    let id: String          // "mui_hat_hoi_lanh", "hong_ho_khan_dem", etc.
    let group: SymptomGroup // .nose, .throatEar
    let title: String
    let triggerDescription: String
}

enum SymptomGroup { case nose, throatEar }
enum EnabledFeature { case weather, camera, audio }
```

**Key files to read** (agent tự đọc):
- `ios/Health360/Design/DesignSystem.swift` — color tokens
- `ios/Health360/Services/APIClient.swift` — HTTP client
- `ios/Health360/App/Health360App.swift` — entry point to simplify
- `docs/presentation-health360-app.html` lines 1–200 (survey screen HTML)

**Exit gate**:
- [ ] App launches without crash (no Firebase dependency)
- [ ] ENTSurveyView renders 4 symptom options in 2 groups
- [ ] Selecting symptoms updates `selectedSymptomIDs` set
- [ ] Tapping "Phân Tích" navigates to AnalysisLoadingView
- [ ] After 2.5s loading, navigates to main tab view
- [ ] `CoinManager.shared.coins` persists across app launches
- [ ] `FeatureGateService` correctly maps symptom IDs to features

**Handoff**: `docs/_handoff/stage-1-done.md`

---

### Stage 2: Daily Loop Screens (Screens 3–5) + Tab Navigation
**Reads**: `docs/_handoff/stage-1-done.md`
**Assumes done**: Models, CoinManager, FeatureGateService, Survey+Loading screens

**Sub-agents**: 2 parallel
- Agent 1 (home-screens): Morning Weather + Noon Camera screens
- Agent 2 (night-screen): Night Audio + Tab bar restructure

**Deliverables**:
- `FE-03`: Gamified header component — user name + disease tag badge + coin badge (orange glow)
- `FE-04`: `MorningWeatherView` — AQI alert card (orange left border, risk %, description). Only visible if `.weather` feature enabled
- `FE-05`: `HabitTaskRow` — tap to complete: strike-through + green checkmark + coin animation
- `FE-06`: `CameraViewfinderView` — corner brackets + scan line animation + "LENS LIVE" pulse. Only if `.camera` enabled
- `FE-07`: Quick-select food buttons (demo mode) — "Lẩu Hải Sản", "Nước Đá Lạnh"
- `FE-08`: `ScanResultCard` — food name badge + red risk text + description + green action box
- `FE-09`: `NightAudioView` — purple accent card, "MIC ACTIVE" pulse, waveform bars animation. Only if `.audio` enabled
- `FE-10`: CTA button "Kích hoạt đo đêm" — request mic permission → +100 coins
- `FE-14`: `MainTabView` restructured — 3 tabs only: 🏠 Trang chủ / 📊 Tổng kết / 🎁 Đổi thưởng

**Home screen structure** (single scrollable view with time-based sections):
```
HomeView
├── GamifiedHeader (name, tag, coins)
├── TimelineSection (icon + time label)
├── IF morning: MorningWeatherCard + HabitTaskRows
├── IF noon: CameraViewfinderCard + ScanResult
├── IF night: NightAudioCard + ClaimButton
```

**Key files to read**:
- `docs/presentation-health360-app.html` lines 200–500 (screens 3-5 HTML)
- `ios/Health360/Services/AudioRecorder.swift`
- `ios/Health360/Services/CameraManager.swift`
- `backend/routes/context.py` — weather API
- `backend/routes/food.py` — food scan API

**Exit gate**:
- [ ] HomeView shows correct section based on time of day (or manual toggle for demo)
- [ ] Weather card shows AQI data (mock or real API call)
- [ ] Camera viewfinder has scan line animation
- [ ] Tapping food button shows result card with ENT risk info
- [ ] Night audio card shows waveform animation
- [ ] "Kích hoạt đo đêm" button adds 100 coins via CoinManager
- [ ] Tab bar has exactly 3 tabs matching design
- [ ] Feature-gated: hiding cards when corresponding feature not enabled

**Handoff**: `docs/_handoff/stage-2-done.md`

---

### Stage 3: Weekly Review + Marketplace + Senior Review (Screens 6–7)
**Reads**: `docs/_handoff/stage-2-done.md`
**Assumes done**: All daily loop screens, coin system, tab navigation

**Sub-agents**: 2 parallel + 1 senior reviewer
- Agent 1 (screens): Weekly review + Marketplace
- Agent 2 (polish): Navigation flow (onboarding → home), state persistence, demo mode toggle

**Deliverables**:
- `FE-11`: `WeeklyReviewView` — Before/After comparison grid (cough count, snore minutes). Red→green color transition
- `FE-12`: Weekly bonus card — total coins earned (large orange text) + "Thu hoạch phần thưởng tuần" CTA
- `FE-13`: `MarketplaceView` — Voucher list cards (name, description, price in coins). "Đổi voucher" button checks balance → deducts or shows alert
- Navigation: App checks if user has completed intake → show survey first time, home after

**Key files to read**:
- `docs/presentation-health360-app.html` lines 500–700 (screens 6-7 HTML)

**Exit gate**:
- [ ] Weekly review shows before/after grid with mock data
- [ ] Claim weekly bonus adds coins
- [ ] Marketplace shows at least 1 voucher
- [ ] Redeem works: deducts coins if sufficient, shows error if not
- [ ] First launch → Survey → Loading → Home. Subsequent launches → Home directly
- [ ] All 7 screens accessible and matching `presentation-health360-app.html` visuals

**Senior Review** (bắt buộc):
```
TASK: Senior review + patch + scope completeness + technology freshness
ROLE: Senior iOS architect / code reviewer
FILES TO REVIEW: All files in ios/Health360/
PLAN DOCUMENT: docs/Plan.html
WORKING DIR: D:\AI\longchau-audio-sed-mvp
REQUIREMENTS:
1. Read Plan.html — list every screen and deliverable
2. Read all Swift files
3. For each screen (1-7): verify view exists, is navigable, matches design
4. Check: MVVM pattern, no force unwraps, proper @State/@StateObject usage
5. Fix bugs directly. Tag severity [P0]–[P3]
6. Verify CoinManager persistence, FeatureGate logic, navigation flow
7. Run build check (swiftc syntax validation if possible)
8. Report: scope checklist, issues+severity, fixes applied
DO NOT: Add features beyond 7 screens, add backend changes
```

**Security Scan**: Scan all Swift files for hardcoded API keys, URLs with credentials, PII.

**Handoff**: `docs/_handoff/stage-3-done.md`

---

## ORCHESTRATOR INSTRUCTIONS

1. Đọc lại `docs/Plan.html` trước khi bắt đầu (stay on track)
2. Chạy Stage 1 bằng `subagent` tool (blocking mode, role: kiro_default)
3. Verify exit gate (grep for files, check structure) + scope completeness
4. PASS → ghi handoff file → proceed Stage 2
5. FAIL → fix trong context, re-verify
6. Lặp cho đến hết stages
7. Stage 3: include senior review + security scan trước commit

## ERROR RECOVERY
- Sub-agent partial output → identify missing files, re-run focused
- Context limit → ghi progress vào handoff, báo user resume point
- Build error → fix immediately, rerun

## FINAL EXIT CRITERIA
- [ ] 7 screens implemented matching `presentation-health360-app.html`
- [ ] Onboarding flow: Survey → Loading → Home
- [ ] Daily loop: Morning weather + Noon camera + Night audio
- [ ] Gamification: Coins earn + persist + spend on vouchers
- [ ] Feature gate: Screens conditionally show content based on intake
- [ ] Tab navigation: 3 tabs (Home / Weekly / Rewards)
- [ ] No Firebase dependency, pure SwiftUI, iOS 16+
- [ ] Senior review: 0 P0–P1 findings
- [ ] Security scan: CLEAN
