# Product Requirements Document (PRD)

## Nama Produk

QR Scanner Pro

## Versi

1.1 (Revisi — update mekanisme scanning terbaru)

## Changelog dari v1.0

* Ditambahkan mekanisme **Auto Zoom** menggantikan pendekatan zoom manual murni sebagai default.
* Ditambahkan dukungan **multi-lens switching** (normal / wide / telephoto) untuk perangkat dengan beberapa kamera belakang.
* FR-03 (Zoom Kamera) direvisi: slider zoom tetap ada, tetapi sekarang sebagai kontrol manual opsional di atas mekanisme auto zoom.
* Ditambahkan FR-08 (Auto Zoom on Detection Failure) dan FR-09 (Lens Switching).
* Update referensi versi package `mobile_scanner` dan minimum SDK Android di bagian Teknologi dan Kompatibilitas.
* Update arsitektur folder Flutter mengikuti struktur fitur yang sudah dibahas (`core/`, `features/`, `models/`, `routes/`).

---

## Platform

* Android
* iOS

## Ringkasan Produk

QR Scanner Pro adalah aplikasi mobile berbasis Flutter yang memungkinkan pengguna melakukan pemindaian QR Code menggunakan kamera perangkat secara real-time. Aplikasi mendukung fitur zoom kamera (manual maupun otomatis), auto-focus, flash, riwayat hasil scan, dan kemampuan membuka URL secara langsung setelah QR berhasil dibaca.

---

# Tujuan Produk

Menyediakan aplikasi QR Scanner yang:

* Cepat dan responsif
* Akurat dalam membaca QR Code, termasuk QR yang jauh, kecil, atau buram
* Mendukung zoom otomatis maupun manual untuk QR yang sulit terbaca
* Mudah digunakan oleh pengguna umum
* Berjalan secara offline untuk proses scanning

---

# Target Pengguna

### Pengguna Umum

* Scan QR pembayaran
* Scan QR WiFi
* Scan QR website
* Scan QR produk

### Pengguna Bisnis

* Verifikasi tiket
* Absensi
* Inventaris

---

# User Story

### US-01 Scan QR

Sebagai pengguna, saya ingin memindai QR Code menggunakan kamera sehingga saya dapat memperoleh informasi dari QR tersebut.

### US-02 Zoom Kamera

Sebagai pengguna, saya ingin memperbesar tampilan kamera (secara manual atau otomatis) sehingga QR yang jauh atau kecil dapat terbaca dengan jelas, tanpa perlu mengatur zoom sendiri jika tidak perlu.

### US-03 Menyalakan Flash

Sebagai pengguna, saya ingin mengaktifkan flash kamera saat kondisi gelap.

### US-04 Melihat Hasil Scan

Sebagai pengguna, saya ingin melihat isi QR yang berhasil dipindai.

### US-05 Menyimpan Riwayat

Sebagai pengguna, saya ingin melihat riwayat QR yang pernah dipindai.

### US-06 Ganti Lensa Kamera (baru)

Sebagai pengguna dengan perangkat berkamera ganda, saya ingin beralih ke lensa wide atau telephoto agar QR yang sangat jauh atau dalam area sempit tetap dapat dipindai dengan jelas.

---

# Functional Requirements

## FR-01 Kamera Scanner

### Deskripsi

Aplikasi membuka kamera belakang secara otomatis saat halaman scanner dibuka.

### Acceptance Criteria

* Kamera aktif dalam ≤ 2 detik
* Menampilkan preview kamera
* Menggunakan auto-focus

---

## FR-02 QR Detection

### Deskripsi

Aplikasi mendeteksi QR Code secara real-time.

### Acceptance Criteria

* QR dapat terbaca dalam ≤ 1 detik
* Scanner berhenti sementara setelah QR berhasil terbaca
* Menampilkan hasil scan

---

## FR-03 Zoom Kamera (Manual)

### Deskripsi

Pengguna dapat melakukan zoom kamera secara manual sebagai kontrol tambahan di atas mekanisme auto zoom (lihat FR-08).

### Acceptance Criteria

* Slider zoom tersedia
* Pinch-to-zoom didukung
* Zoom minimal 1x
* Zoom maksimal mengikuti kemampuan perangkat (hingga 10x atau lebih)
* Nilai zoom awal (`initialZoom`) dapat dikonfigurasi agar scanner tidak selalu mulai dari 1x

### UI

Slider:

```
[ 1x ----------- 10x ]
```

---

## FR-04 Flash Control

### Deskripsi

Mengaktifkan atau menonaktifkan flash kamera.

### Acceptance Criteria

* Tombol Flash ON/OFF tersedia
* Status flash terlihat jelas

---

## FR-05 Riwayat Scan

### Deskripsi

Menyimpan hasil scan lokal.

### Acceptance Criteria

* Data tersimpan di SQLite
* Menampilkan:

  * Isi QR
  * Tanggal Scan
  * Tipe QR

---

## FR-06 Salin Hasil

### Deskripsi

Menyalin hasil scan ke clipboard.

### Acceptance Criteria

* Tombol Copy tersedia
* Muncul notifikasi berhasil

---

## FR-07 Buka URL

### Deskripsi

Jika hasil scan berupa URL maka dapat dibuka langsung.

### Acceptance Criteria

* Tombol Open URL muncul otomatis
* Membuka browser default perangkat

---

## FR-08 Auto Zoom on Detection Failure (baru)

### Deskripsi

Ketika sebuah QR Code terdeteksi dalam frame tetapi terlalu kecil/jauh untuk dapat dibaca, sistem secara otomatis memperbesar (zoom in) area tersebut untuk mendapatkan pembacaan yang jelas, tanpa memerlukan input manual dari pengguna. Mekanisme ini tersedia melalui parameter `autoZoom` pada controller scanner.

### Acceptance Criteria

* Auto zoom aktif secara default, dapat dimatikan dari Settings jika pengguna lebih memilih kontrol manual penuh
* Saat QR terdeteksi namun tidak terbaca karena ukurannya kecil dalam frame, kamera melakukan zoom in secara bertahap hingga QR terbaca atau batas zoom maksimal tercapai
* Tidak mengganggu kecepatan scan untuk QR yang sudah dalam jarak baca normal (tidak ada delay tambahan jika QR sudah cukup besar di frame)
* Slider zoom manual (FR-03) tetap dapat menimpa (override) posisi zoom otomatis kapan saja

---

## FR-09 Lens Switching (baru)

### Deskripsi

Pada perangkat dengan lebih dari satu kamera belakang (normal, wide, telephoto/zoom), pengguna dapat beralih jenis lensa untuk menyesuaikan jarak pandang pemindaian.

### Acceptance Criteria

* Tombol/ikon switch lensa hanya muncul jika perangkat mendukung lebih dari satu jenis lensa (dideteksi melalui pengecekan lensa yang didukung)
* Mendukung perpindahan berurutan antar lensa (normal → wide → zoom → normal)
* Pengguna juga dapat memilih lensa tertentu secara langsung (misalnya langsung ke lensa wide)
* Perpindahan lensa tidak menghentikan sesi scanning yang sedang berjalan

---

# Non Functional Requirements

## Performa

* Startup < 3 detik
* Scan QR < 1 detik (untuk QR dalam jarak baca normal; auto zoom dapat menambah waktu pada kondisi QR sangat kecil/jauh)
* FPS preview kamera ≥ 30

## Kompatibilitas

### Android

* Android 8+ (API 26+) untuk aplikasi secara umum
* Catatan: dependensi native scanner mensyaratkan minimum SDK 23; pastikan `minSdkVersion` proyek mengikuti batas yang lebih tinggi di antara keduanya

### iOS

* iOS 14+

## Keamanan

* Tidak mengirim data scan ke server
* Semua data disimpan lokal

---

# Teknologi

## Flutter Version

Flutter 3.35+ (dependensi scanner mensyaratkan minimum Flutter 3.29+)

## State Management

* Riverpod

## Database

* SQLite
* Hive (opsional)

## Package

### Scanner

* `mobile_scanner` — menggunakan CameraX/ML Kit di Android, AVFoundation/Apple Vision di iOS, dan ZXing untuk web. Mendukung deteksi real-time, auto zoom, multi-lens switching, dan kontrol zoom manual.

### Camera

* `camera` (hanya jika dibutuhkan capture foto/video di luar flow scanning; tidak diperlukan untuk fungsi scanning inti karena sudah ditangani `mobile_scanner`)

### Local Storage

* `sqflite`

### Open URL

* `url_launcher`

### Permission

* `permission_handler`

### Catatan Ukuran Aplikasi

`mobile_scanner` secara default menyertakan versi *bundled* ML Kit Barcode-scanning di Android, yang menambah ukuran APK sekitar 3–10 MB namun langsung tersedia tanpa unduhan tambahan. Tersedia juga opsi versi *unbundled* yang diunduh saat pertama digunakan via Google Play Services dengan tambahan ukuran APK jauh lebih kecil (~600 KB) — opsi ini dapat dipertimbangkan jika ukuran aplikasi menjadi prioritas utama.

---

# UI Flow

## Halaman Scanner

### Header

QR Scanner

`[ Flash ] [ Switch Lens ] [ History ]`

---

```
  ┌──────────────┐
  │              │
  │   Scan QR    │
  │  (auto zoom  │
  │   aktif)     │
  └──────────────┘
```

---

Zoom manual (override)

```
[1x =======|======= 10x]
```

---

## Halaman Result

QR Result

---

https://example.com

`[ Copy ]`

`[ Open URL ]`

`[ Scan Again ]`

---

## Halaman History

Riwayat Scan

---

1. https://example.com
   21-06-2026 10:00

2. WIFI:SAMPLE
   21-06-2026 09:50

---

# Database Schema

Table: scan_history

| Field      | Type     |
| ---------- | -------- |
| id         | INTEGER  |
| content    | TEXT     |
| type       | TEXT     |
| scanned_at | DATETIME |

---

# Arsitektur Flutter

```
lib/
├── main.dart
├── core/
│   ├── database/
│   ├── services/
│   └── utils/
├── features/
│   ├── scanner/
│   │   ├── pages/
│   │   ├── widgets/
│   │   └── providers/
│   ├── history/
│   └── settings/
├── models/
└── routes/
```

---

# Future Enhancement

## V1.1 (terealisasi sebagian di revisi ini)

* ~~Scan Barcode~~ (dapat dicapai langsung karena `mobile_scanner` sudah mendukung berbagai format barcode selain QR)
* Scan DataMatrix
* Export Riwayat CSV

## V1.2

* Batch Scan
* OCR Text Scanner
* Scan dari Galeri

## V2.0

* Cloud Sync
* Multi Device History
* QR Generator

---

# Success Metrics

* Scan Success Rate ≥ 98%
* Crash Rate ≤ 0.5%
* Average Scan Time ≤ 1 detik (untuk QR dalam jarak baca normal)
* User Rating ≥ 4.5/5

---

# Referensi

* Dokumentasi resmi package `mobile_scanner` (pub.dev) — parameter `autoZoom`, `initialZoom`, dan API `switchCamera()` untuk multi-lens.
* Changelog dan rilis `mobile_scanner` di GitHub — riwayat penambahan fitur auto zoom dan lens switching.