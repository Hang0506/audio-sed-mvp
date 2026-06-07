# Stage 3 Done — iOS Core Screens

> Completed: 2026-06-05

## Project Structure

```
ios/Health360/
├── App/
│   └── Health360App.swift          — @main, Firebase init, dark mode
├── Design/
│   ├── DesignSystem.swift          — Colors, fonts, spacing tokens
│   └── Components/
│       ├── CircularGauge.swift     — Progress ring (Uric display)
│       ├── AlertCard.swift         — Left-border alert card
│       ├── ContextTile.swift       — Weather/AQI data tile
│       ├── BadgeTag.swift          — Pill badge
│       └── TaskCheckRow.swift      — Checklist item + coins
├── Views/
│   ├── MainTabView.swift           — 5-tab navigation
│   ├── Home/
│   │   └── DashboardView.swift     — Full dashboard (gauge, context, alerts, tasks)
│   ├── Profile/
│   │   └── IntakeWizardView.swift  — 3-step onboarding wizard
│   └── Checkout/
│       └── ExpressCheckoutView.swift — Product + GPS + confirm + tracking
├── Services/
│   ├── APIClient.swift             — Async networking singleton
│   └── NotificationManager.swift   — Push notification handling
└── Models/
    ├── User.swift
    ├── ContextData.swift
    ├── Alert.swift
    └── Product.swift
```

## Design System Tokens

| Token | Value |
|-------|-------|
| bg | #0f172a |
| card | #1e293b |
| textPrimary | #f1f5f9 |
| muted | #94a3b8 |
| accentBlue | #38bdf8 |
| accentTeal | #14b8a6 |
| accentOrange | #f97316 |
| accentPurple | #a78bfa |
| accentRed | #ef4444 |

## Screens Implemented

| FE Task | Screen | Status |
|---------|--------|--------|
| FE-1 | Layout + Design System + Permissions | ✅ |
| FE-2 | Intake Wizard (3-step) | ✅ |
| FE-3 | Dashboard Home | ✅ |
| FE-4 | Push Notification Manager | ✅ |
| FE-9 | Express Checkout + Tracking | ✅ |

## API Integration Points (wired but using mock data)

- POST /api/v1/user/intake (IntakeWizardView submit)
- GET /api/v1/context/{user_id} (DashboardView refresh)
- POST /api/v1/order/create (ExpressCheckoutView confirm)

## Still Needed (Stage 4)

- FE-5: Scanner (Audio + Camera)
- FE-6: Metrics Chart
- FE-7: Alert Detail
- FE-8: Rewards Center
- FE-10: Cough Recommendation
- FE-11: Sleep Assessment
- FE-12: Food Camera
- FE-13: Food Result
