# Flutter WebView App dengan Domain Lock dan Ad Blocking

Aplikasi Flutter browser berbasis WebView dengan sistem proteksi keamanan **Domain Lock** dan **Ad Blocking**. Aplikasi ini dirancang khusus untuk mengunci akses navigasi hanya pada domain utama yang ditentukan beserta subdomainnya, serta mencegah kebocoran navigasi ke domain eksternal, aplikasi lain, atau jaringan iklan.

---

## 📱 Prebuilt APK

File APK release yang sudah dikompilasi tersedia langsung:
- Lokasi di repositori: [`webview-domain-lock.apk`](./webview-domain-lock.apk)
- Siap di-download dan di-install pada perangkat Android (Android 5.0+ / SDK 21+).

---

## ✨ Fitur Utama

1. **URL Input & Auto-Save:**
   - Menampilkan modal input URL saat pertama kali aplikasi dijalankan.
   - Normalisasi URL otomatis (menambahkan `https://` jika protokol tidak disertakan).
   - Menyimpan URL utama secara lokal (`shared_preferences`) dan otomatis memuatnya saat aplikasi dibuka kembali.
2. **Domain Lock (Allowlist-Based):**
   - Hanya mengizinkan domain utama dan subdomainnya (contoh: `example.com`, `www.example.com`, `api.example.com`).
   - Mencegah teknik bypass domain seperti `example.com.evil.com`.
3. **Navigation & Redirect Interception:**
   - Memeriksa setiap perpindahan halaman dan redirect website sebelum dieksekusi.
   - Menggagalkan redirect yang mengarah ke luar domain yang diizinkan.
4. **External App & Browser Blocking:**
   - Hanya skema `http://` dan `https://` yang diperbolehkan.
   - Memblokir skema eksternal seperti `intent://`, `market://`, `whatsapp://`, `mailto:`, `tel:`, `tg:`, dll.
   - Tidak pernah membuka browser eksternal (Chrome / Custom Tabs).
5. **Popup & New Window Blocking:**
   - Mencegah pembukaan window baru atau popup (`window.open()` dan target `_blank`).
   - Merute ulang navigasi popup ke frame utama agar tetap terkontrol oleh aturan navigasi.
6. **Ad & Tracker Blocking:**
   - Memiliki daftar blokir bawaan (`ad_blocklist.dart`) untuk jaringan iklan populer (DoubleClick, AdSense, Taboola, Outbrain, dll.).
   - Mendukung pencocokan subdomain iklan (seperti `securepubads.g.doubleclick.net`).
7. **UX & State Handling:**
   - Loading indicator dengan persentase kemajuan pemuatan.
   - Error page informatif dilengkapi tombol **Retry**.
   - Integrasi tombol back Android dengan history navigasi WebView.
   - Menu pengaturan untuk mengubah URL utama kapan saja.

---

## 📁 Struktur Project

```
lib/
├── main.dart
├── app/
│   └── app.dart
├── features/
│   └── webview/
│       ├── presentation/
│       │   ├── pages/
│       │   │   └── webview_page.dart
│       │   └── widgets/
│       │       ├── url_input_dialog.dart
│       │       └── loading_overlay.dart
│       ├── services/
│       │   ├── webview_navigation_service.dart
│       │   └── webview_adblock_service.dart
│       └── models/
│           └── webview_config.dart
├── core/
│   ├── constants/
│   │   └── ad_blocklist.dart
│   ├── services/
│   │   └── storage_service.dart
│   └── utils/
│       ├── url_utils.dart
│       └── domain_utils.dart
```

---

## 🚀 Menjalankan Project

### Prasyarat
- Flutter SDK (3.x)
- Android SDK (Platform 34/36)
- Java 17+

### Install Dependencies
```bash
flutter pub get
```

### Jalankan Tes
```bash
flutter test
```

### Build APK
```bash
flutter build apk --release
```
Hasil build akan berada di `build/app/outputs/flutter-apk/app-release.apk`.
