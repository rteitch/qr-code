# QR Scanner Pro

<p align="center">
  <img src="qrscanner-logo.png" width="150" alt="QR Scanner Pro Logo"/>
</p>

Aplikasi mobile berbasis **Flutter** untuk memindai QR Code secara real-time dengan fitur auto zoom, multi-lens switching, riwayat scan, dan kemampuan membuka URL langsung.

---

## ✨ Fitur

| Fitur | Deskripsi |
|-------|-----------|
| 📷 **Real-time QR Scanning** | Deteksi QR Code secara langsung dari kamera perangkat |
| 🔍 **Auto Zoom** | Zoom otomatis saat QR terlalu kecil atau jauh |
| 🎚️ **Manual Zoom** | Slider zoom 1x–10x + pinch-to-zoom |
| 📸 **Multi-Lens Switch** | Beralih antar lensa (normal/wide/telephoto) pada perangkat multi-kamera |
| 🔦 **Flash Control** | Aktifkan/nonaktifkan flash untuk kondisi gelap |
| 📋 **Copy to Clipboard** | Salin hasil scan ke clipboard |
| 🌐 **Open URL** | Buka URL langsung di browser jika QR berisi link |
| 📜 **Scan History** | Simpan dan kelola riwayat scan lokal (SQLite) |
| 🗑️ **Swipe to Delete** | Hapus riwayat dengan swipe atau hapus semua sekaligus |
| ⚙️ **Settings** | Toggle auto zoom, info aplikasi |
| 🎨 **Dark Theme** | UI modern dengan Material 3 dark theme |

---

## 📱 Platform

| Platform | Minimum Version |
|----------|----------------|
| Android | API 26+ (Android 8.0) |
| iOS | iOS 14+ |

---

## 🛠️ Teknologi

| Teknologi | Package | Versi |
|-----------|---------|-------|
| **Framework** | Flutter | 3.44+ |
| **Language** | Dart | 3.12+ |
| **State Management** | flutter_riverpod | 2.6.1 |
| **Scanner** | mobile_scanner | 6.0.x |
| **Database** | sqflite | 2.4.x |
| **Navigation** | go_router | 14.x |
| **URL Launcher** | url_launcher | 6.x |
| **Permissions** | permission_handler | 11.x |

---

## 📂 Struktur Proyek

```
lib/
├── main.dart                              # Entry point
├── core/
│   ├── database/
│   │   └── database_helper.dart           # SQLite helper (CRUD)
│   ├── services/
│   │   └── url_service.dart               # URL launcher service
│   └── utils/
│       └── constants.dart                 # Konstanta, warna, string
├── features/
│   ├── scanner/
│   │   ├── pages/
│   │   │   ├── scanner_page.dart          # Halaman scanner utama
│   │   │   └── result_page.dart           # Halaman hasil scan
│   │   ├── widgets/
│   │   │   └── zoom_slider.dart           # Widget slider zoom
│   │   └── providers/
│   │       └── scanner_provider.dart      # State scanner
│   ├── history/
│   │   ├── pages/
│   │   │   └── history_page.dart          # Halaman riwayat
│   │   └── providers/
│   │       └── history_provider.dart      # State riwayat
│   └── settings/
│       ├── pages/
│       │   └── settings_page.dart         # Halaman pengaturan
│       └── providers/
│           └── settings_provider.dart     # State pengaturan
├── models/
│   └── scan_history.dart                  # Model scan history
└── routes/
    └── app_router.dart                    # Konfigurasi routing
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.35+ ([Install Flutter](https://docs.flutter.dev/get-started/install))
- Android Studio / Xcode
- Android SDK (API 26+)

### Installation

1. **Clone repository**
   ```bash
   git clone <repository-url>
   cd qr-code
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run aplikasi**
   ```bash
   # Android
   flutter run

   # iOS
   flutter run -d ios
   ```

### Build APK

```bash
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk
```

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

---

## 📖 Cara Penggunaan

### 1. Scan QR Code
- Buka aplikasi → halaman scanner otomatis aktif
- Arahkan kamera ke QR Code
- Hasil scan akan muncul di halaman Result

### 2. Zoom Kamera
- **Auto Zoom**: Aktif secara default, otomatis zoom saat QR terlalu kecil
- **Manual Zoom**: Gunakan slider di bawah kamera atau pinch-to-zoom
- **Pengaturan**: Matikan auto zoom di halaman Settings jika ingin kontrol manual penuh

### 3. Ganti Lensa
- Tekan ikon 🔄 (Switch Lens) di header scanner
- Berputar: Normal → Wide → Telephoto → Normal

### 4. Flash
- Tekan ikon ⚡ untuk menyalakan/mematikan flash

### 5. Lihat Riwayat
- Tekan ikon 📜 (History) di header scanner
- Tap item untuk melihat detail
- Swipe kiri untuk menghapus item
- Tekan ikon 🗑️ untuk menghapus semua riwayat

### 6. Hasil Scan
- **Copy**: Salin isi QR ke clipboard
- **Open URL**: Buka link di browser (muncul otomatis untuk QR tipe URL)
- **Scan Again**: Kembali ke scanner

---

## 🗄️ Database Schema

**Table: `scan_history`**

| Field | Type | Keterangan |
|-------|------|------------|
| id | INTEGER | Primary key (auto-increment) |
| content | TEXT | Isi QR Code |
| type | TEXT | Tipe QR (URL, WIFI, EMAIL, PHONE, SMS, CONTACT, LOCATION, TEXT) |
| scanned_at | DATETIME | Waktu scan |

---

## ⚙️ Konfigurasi

### Android

- **minSdkVersion**: 26 (Android 8.0)
- **Permissions**: CAMERA, INTERNET, FLASHLIGHT
- **Manifest**: `android/app/src/main/AndroidManifest.xml`

### iOS

- **Minimum**: iOS 14+
- **NSCameraUsageDescription** sudah dikonfigurasi di `ios/Runner/Info.plist`

---

## 📄 License

This project is for educational purposes.

---

## 🙏 Acknowledgments

- [mobile_scanner](https://pub.dev/packages/mobile_scanner) — QR/Barcode scanner
- [flutter_riverpod](https://pub.dev/packages/flutter_riverpod) — State management
- [sqflite](https://pub.dev/packages/sqflite) — SQLite database
- [go_router](https://pub.dev/packages/go_router) — Declarative routing