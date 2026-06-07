# AI Health 360 — Hướng dẫn chạy toàn bộ

## 1. Yêu cầu hệ thống

- Python 3.11+ (khuyến nghị 3.12)
- pip
- Git
- (iOS) Xcode 15+ trên macOS (chỉ khi cần build iOS app)

---

## 2. Chạy Backend

### Bước 1: Cài dependencies

```bash
cd backend
pip install -r requirements.txt
```

> Nếu gặp lỗi `librosa` hoặc `onnxruntime` → cài thêm:
> ```bash
> pip install soundfile
> ```

### Bước 2: Download model YAMNet (lần đầu)

```bash
python download_model.py
```

File `models/yamnet.onnx` (~16MB) sẽ được tải về.

### Bước 3: Cấu hình `.env`

Tạo file `backend/.env` (đã có sẵn nếu clone repo này):

```env
# Bắt buộc — lấy tại https://openweathermap.org/api (free)
OPENWEATHERMAP_API_KEY=your_openweathermap_api_key_here

# Tùy chọn — FCM push notification
FIREBASE_CREDENTIALS_PATH=

# Tùy chọn — Telegram Ops (food labeling)
TELEGRAM_BOT_TOKEN=
TELEGRAM_CHAT_ID=
```

> ⚠️ Key OpenWeatherMap mới tạo cần **10 phút - 2 giờ** để kích hoạt.
> Trong khi chờ, hệ thống tự dùng mock data (HCM: 32°C, 78%, PM2.5=85).

### Bước 4: Chạy server

```bash
cd backend
uvicorn app:app --reload --host 0.0.0.0 --port 8000
```

Server chạy tại: **http://localhost:8000**

### Bước 5: Test API

```bash
# Health check
curl http://localhost:8000/api/samples

# Tạo user profile
curl -X POST http://localhost:8000/api/v1/user/intake \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"Nguyen Van A\",\"disease_tags\":[\"ENT\",\"Gout\"],\"lat\":10.82,\"long\":106.63}"

# Xem thời tiết + PM2.5
curl http://localhost:8000/api/v1/context/USER_ID_TRA_VE_O_TREN

# Test rule engine (dùng mock users)
curl -X POST http://localhost:8000/api/v1/alerts/evaluate \
  -H "Content-Type: application/json" \
  -d "{\"user_id\":\"user_001\"}"

# Sleep assessment
curl -X POST http://localhost:8000/api/sleep-assessment \
  -H "Content-Type: application/json" \
  -d "{\"snoring_freq\":\"every_night\",\"daytime_sleepiness\":\"severe\",\"apnea_observed\":\"yes\",\"body_type\":\"obese\"}"

# Food scan (mock mode - trả random foods)
curl -X POST http://localhost:8000/api/food-scan \
  -F "file=@any_image.jpg" \
  -F "user_id=USER_ID"

# O2O Checkout
curl -X POST http://localhost:8000/api/v1/order/create \
  -H "Content-Type: application/json" \
  -d "{\"user_id\":\"abc\",\"product_id\":\"p1\",\"product_name\":\"Bo rua mui\",\"quantity\":1,\"delivery_lat\":10.82,\"delivery_long\":106.63}"

# Audio analysis (cần file WAV)
curl -X POST http://localhost:8000/api/analyze \
  -F "file=@recording.wav" \
  -F "mode=v2"
```

---

## 3. API Endpoints tổng hợp

| Method | Endpoint | Mô tả |
|--------|----------|--------|
| GET | /api/samples | Liệt kê file WAV mẫu |
| POST | /api/analyze | Phân tích audio (ho/ngáy/thở) |
| POST | /api/recommendation | Khuyến nghị theo loại ho |
| GET | /api/recommendation/options | Options cho form assessment |
| POST | /api/v1/user/intake | Tạo profile user |
| GET | /api/v1/user/profile/{id} | Xem profile |
| POST | /api/v1/user/device-token | Cập nhật FCM token |
| GET | /api/v1/context/{user_id} | Thời tiết + PM2.5 |
| POST | /api/sleep-assessment | Sàng lọc OSA |
| POST | /api/v1/alerts/evaluate | Test rule engine |
| POST | /api/food-scan | Quét ảnh thức ăn |
| POST | /api/v1/order/create | Tạo đơn hàng O2O |
| GET | /api/v1/order/{id} | Xem đơn hàng |
| POST | /api/v1/analytics/event | Track sự kiện |

---

## 4. Chạy Frontend Web (có sẵn)

Frontend web tự serve khi backend chạy → mở **http://localhost:8000** trên browser.

Giao diện web cho phép:
- Ghi âm → phân tích ho/ngáy
- Xem kết quả phân loại ho khan/đờm
- Form khảo sát → nhận khuyến nghị

---

## 5. iOS App (cần macOS + Xcode)

### Bước 1: Tạo Xcode project

1. Mở Xcode → File → New → Project → iOS → App
2. Product Name: `Health360`
3. Interface: SwiftUI, Language: Swift
4. Minimum Deployment: iOS 16.0
5. Xóa file ContentView.swift mặc định

### Bước 2: Add source files

1. Xóa thư mục `Health360` mặc định trong project
2. Kéo thả toàn bộ thư mục `ios/Health360/` vào Xcode project navigator
3. Check "Copy items if needed" + "Create groups"

### Bước 3: Thêm Firebase (SPM)

1. File → Add Package Dependencies
2. URL: `https://github.com/firebase/firebase-ios-sdk`
3. Chọn: FirebaseMessaging, FirebaseAnalytics
4. Thêm `GoogleService-Info.plist` (từ Firebase Console)

### Bước 4: Thêm Swift Charts

Đã có sẵn trong iOS 16+ — không cần add thêm.

### Bước 5: Cấu hình Info.plist permissions

```xml
<key>NSMicrophoneUsageDescription</key>
<string>Ứng dụng cần microphone để phân tích âm thanh hô hấp</string>
<key>NSCameraUsageDescription</key>
<string>Ứng dụng cần camera để quét thực phẩm</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Ứng dụng cần vị trí để lấy dữ liệu chất lượng không khí</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>Ứng dụng theo dõi chất lượng không khí theo vị trí của bạn</string>
```

### Bước 6: Đổi API base URL

Mở `ios/Health360/Services/APIClient.swift`, đổi `baseURL`:

```swift
// Chạy local
private let baseURL = "http://localhost:8000"

// Chạy trên device thật (thay IP máy)
private let baseURL = "http://192.168.1.xxx:8000"
```

### Bước 7: Build & Run

Cmd+R → chạy trên Simulator hoặc device.

---

## 6. Cấu trúc thư mục

```
longchau-audio-sed-mvp/
├── backend/
│   ├── app.py                  ← Main FastAPI server
│   ├── .env                    ← API keys (KHÔNG commit)
│   ├── requirements.txt        ← Python dependencies
│   ├── models/                 ← ONNX models + data
│   ├── routes/                 ← API route handlers
│   ├── services/               ← Business logic
│   ├── config/                 ← Rules JSON
│   └── storage/                ← JSON DBs + recordings
├── frontend/                   ← Web UI (auto-served)
├── ios/Health360/              ← iOS SwiftUI source
└── docs/                       ← Plans, handoffs, SDD
```

---

## 7. Mock Mode vs Real Mode

| Feature | Không có env var → | Có env var → |
|---------|-------------------|--------------|
| Thời tiết/PM2.5 | Mock HCM (32°C, PM2.5=85) | Data thật theo GPS |
| FCM Push | Log alert ra console | Gửi push thật |
| Food Detection | Random 1-3 món Việt | YOLOv10 inference thật (cần file .onnx) |
| Telegram Ops | Log intent | Gửi ảnh qua Telegram bot |

Mọi thứ hoạt động ở mock mode — không cần key nào cũng chạy được, chỉ là data giả.

---

## 8. Troubleshooting

| Lỗi | Giải pháp |
|-----|-----------|
| `ModuleNotFoundError` | `pip install -r requirements.txt` |
| `yamnet.onnx not found` | `python download_model.py` |
| OpenWeatherMap 401 | Key mới cần 10ph-2h kích hoạt, hoặc key sai |
| Port 8000 bị chiếm | `uvicorn app:app --port 8001` |
| iOS build lỗi Firebase | Thêm SPM package firebase-ios-sdk |
| `httpx` not found | `pip install httpx` |
