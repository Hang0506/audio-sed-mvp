# Hướng dẫn chạy Android Health360 trên Windows

## Yêu cầu hệ thống

- Windows 10/11 64-bit
- RAM tối thiểu 8GB (recommend 16GB vì emulator ngốn RAM)
- Android Studio (latest stable — Koala 2024+)
- JDK 17 (Android Studio tự bundle)

---

## Bước 1: Cài Android Studio

Nếu chưa có:
1. Download: https://developer.android.com/studio
2. Cài đặt → chọn **Standard** setup
3. Đợi SDK Manager download xong (SDK 34, Build Tools, Emulator)

---

## Bước 2: Mở project

1. Mở Android Studio
2. **File → Open** → chọn thư mục `D:\AI\longchau-audio-sed-mvp\android`
3. Đợi Gradle sync xong (lần đầu ~3-5 phút tải dependencies)

### Nếu Gradle sync lỗi Firebase:

Vì chưa có `google-services.json`, cần comment tạm:

**File `android/build.gradle.kts`** — comment dòng google-services:
```kotlin
plugins {
    id("com.android.application") version "8.4.0" apply false
    id("org.jetbrains.kotlin.android") version "1.9.22" apply false
    // id("com.google.gms.google-services") version "4.4.0" apply false  // ← COMMENT
}
```

**File `android/app/build.gradle.kts`** — comment plugin + firebase deps:
```kotlin
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // id("com.google.gms.google-services")  // ← COMMENT
}

// Trong dependencies {}, comment 3 dòng Firebase:
    // implementation(platform("com.google.firebase:firebase-bom:32.7.0"))
    // implementation("com.google.firebase:firebase-messaging-ktx")
    // implementation("com.google.firebase:firebase-analytics-ktx")
```

**File `Health360App.kt`** — bỏ Firebase import:
```kotlin
package com.health360.app

import android.app.Application
// import com.google.firebase.FirebaseApp  // ← COMMENT

class Health360App : Application() {
    override fun onCreate() {
        super.onCreate()
        // FirebaseApp.initializeApp(this)  // ← COMMENT
    }
}
```

Sau đó **File → Sync Project with Gradle Files** (hoặc click biểu tượng voi 🐘 trên toolbar).

---

## Bước 3: Tạo Android Emulator

1. Trong Android Studio: **Tools → Device Manager** (hoặc biểu tượng điện thoại bên phải)
2. Click **Create Device**
3. Chọn hardware:
   - Category: **Phone**
   - Device: **Pixel 7** (hoặc bất kỳ)
   - Click **Next**
4. Chọn System Image:
   - Tab **Recommended**
   - Chọn **UpsideDownCake (API 34)** — click **Download** nếu chưa có (~ 1.2GB)
   - Click **Next**
5. AVD Name: đặt tên tuỳ ý (vd: `Pixel_7_API_34`)
6. Click **Finish**

### Tips tăng tốc emulator:
- Bật **Hardware Acceleration**: Settings → Android SDK → SDK Tools → tick "Intel HAXM" hoặc dùng Windows Hypervisor Platform
- Trong Windows: Settings → Apps → Optional Features → bật **Windows Hypervisor Platform**
- Restart máy sau khi bật

---

## Bước 4: Chạy Backend (trên cùng máy Windows)

Mở terminal (PowerShell hoặc cmd):

```powershell
cd D:\AI\longchau-audio-sed-mvp\backend

# Tạo virtualenv (lần đầu)
python -m venv venv
.\venv\Scripts\activate

# Cài dependencies
pip install -r requirements.txt

# Chạy server
python app.py
```

Server chạy tại `http://localhost:8000`.

**Quan trọng**: Android Emulator truy cập localhost của máy host qua IP `10.0.2.2`. Đã config sẵn trong `ApiClient.kt`:
```kotlin
var baseUrl = "http://10.0.2.2:8000"
```

Nếu test trên **điện thoại thật** qua USB/WiFi → đổi thành IP LAN của máy (vd: `http://192.168.1.100:8000`).

---

## Bước 5: Chạy app

1. Trên toolbar Android Studio, chọn device vừa tạo (dropdown bên trái nút Run ▶)
2. Click **Run ▶** (hoặc Shift+F10)
3. Đợi build + install (~1-2 phút lần đầu)
4. App hiện trên emulator → 5 tabs bên dưới

---

## Bước 6: Test từng màn hình

| Tab | Màn hình | Cách test |
|-----|----------|-----------|
| Trang chủ | Dashboard | Xem gauge, context tiles, tasks. Pull-to-refresh (nếu backend chạy) |
| Chỉ số | Metrics | Chuyển tab Axit Uric / Hô Hấp / Tiểu Đường / Huyết Áp |
| Quét | Scanner | Toggle Hô Hấp → bấm mic → đếm 5s → hiện kết quả. Toggle Dinh Dưỡng → Chụp |
| Thưởng | Rewards | Xem xu, bấm ĐỔI QUÀ → dialog confirm |
| Hồ sơ | Intake Wizard | Chọn bệnh nền → Tiếp tục → Triệu chứng → Tiếp tục → Nhập chỉ số → Gửi |

### Test flow Scanner → Recommendation:
1. Tab **Quét** → mode **Hô Hấp**
2. Bấm nút mic tím → đếm ngược 5s
3. Hiện kết quả "Ho khan 89%"
4. Bấm **Xem khảo sát ho** → CoughRecommendationScreen
5. Điền form → bấm **Gửi khảo sát** → xem recommendations

### Test flow Food Scanner:
1. Tab **Quét** → mode **Dinh Dưỡng**
2. Bấm **Chụp thực phẩm** → FoodCameraScreen
3. Bấm capture → loading 2s → FoodResultScreen
4. Xem detected foods, nutrition, risk alerts

---

## Troubleshooting

| Lỗi | Nguyên nhân | Cách fix |
|-----|------------|----------|
| Gradle sync fail "google-services.json not found" | Chưa có Firebase config | Comment Firebase (xem Bước 2) |
| Emulator không mở | Chưa bật Virtualization | BIOS → enable VT-x/AMD-V. Bật Windows Hypervisor Platform |
| App crash "Network on main thread" | Không xảy ra (dùng coroutines) | — |
| API call fail | Backend chưa chạy hoặc sai URL | Kiểm tra backend ở port 8000. Emulator dùng `10.0.2.2` |
| Build quá lâu (>10 phút) | Máy yếu / RAM ít | Tắt bớt app, tăng Gradle heap: `org.gradle.jvmargs=-Xmx4g` trong gradle.properties |
| "SDK location not found" | Chưa config local.properties | Tạo file `android/local.properties` với nội dung: `sdk.dir=C:\\Users\\USER\\AppData\\Local\\Android\\Sdk` |

---

## Sau khi test UI xong — Thêm Firebase (optional)

1. Vào https://console.firebase.google.com
2. Tạo project hoặc dùng project có sẵn
3. **Add App → Android** → package name: `com.health360.app`
4. Download `google-services.json` → đặt vào `android/app/`
5. Uncomment lại tất cả dòng Firebase đã comment ở Bước 2
6. Sync Gradle → Run lại

---

## Cấu trúc project (quick reference)

```
android/app/src/main/java/com/health360/app/
├── MainActivity.kt          ← Entry point
├── Health360App.kt          ← Application class
├── data/
│   ├── model/Models.kt      ← Data classes
│   └── network/ApiClient.kt ← Retrofit API (10.0.2.2:8000)
├── services/
│   └── FCMService.kt        ← Push notifications
└── ui/
    ├── theme/               ← Colors, Theme
    ├── components/          ← Reusable UI (Gauge, Tiles, etc.)
    ├── navigation/          ← Bottom nav + routing
    └── screens/             ← All screens (13 files)
```
