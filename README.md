# 🎬 IDLIX-App — Android TV, STB & Mobile Streaming Client

[![GitHub Release](https://img.shields.io/github/v/release/Asadaaaaa/IDLIX-App?color=blue&label=Release)](https://github.com/Asadaaaaa/IDLIX-App/releases)
[![Platform](https://img.shields.io/badge/Platform-Android%20TV%20%7C%20STB%20%7C%20Mobile-green)](https://github.com/Asadaaaaa/IDLIX-App)
[![Flutter](https://img.shields.io/badge/Built%20with-Flutter%203-02569B)](https://flutter.dev)

Aplikasi browser streaming khusus **IDLIX** berbasis Flutter WebView berperforma tinggi, dirancang untuk berjalan optimal di **Android TV**, **Google TV**, **Android Box (STB)**, maupun **Smartphone & Tablet Android**.

Aplikasi ini mengatasi masalah umum saat mengakses situs streaming:
- **Bebas Iklan & Redirect:** Dilengkapi proteksi **Domain Lock** dan **Ad Blocking** untuk mencegah popup, tab baru jebakan, dan iklan berbahaya.
- **Ramah Remote TV:** Menggunakan **Virtual Mouse (Kursor Layar D-Pad)** dengan akselerasi halus dan auto-scroll untuk kemudahan navigasi di TV tanpa mouse fisik.
- **Domain IDLIX Selalu Terkini:** Menggunakan sistem **Dynamic URL dari GitHub Raw**, sehingga jika alamat website IDLIX berganti, URL diperbarui langsung dari file `config.json` di GitHub tanpa perlu update aplikasi.
- **Deteksi Stream & Cast Video:** Menangkap stream video (HLS `.m3u8` / `.mp4`) beserta subtitle (Bahasa Indonesia & Inggris) dan dapat di-cast langsung ke **Smart TV / Chromecast / DLNA**.

---

## 📱 Download APK Release

Tersedia dalam **2 APK terpisah** yang dioptimalkan secara spesifik untuk masing-masing perangkat:

| Perangkat | Nama Aplikasi | File APK | Keterangan |
|---|---|---|---|
| 📱 **HP & Tablet Android** | **IDLIX** | [`IDLIX.apk`](./IDLIX.apk) | Layar penuh tanpa navbar, navigasi sentuh native, auto-detect cast video |
| 📺 **Android TV & STB Box** | **IDLIX TV** | [`IDLIX-TV.apk`](./IDLIX-TV.apk) | Banner Leanback launcher TV, kursor D-Pad remote, auto-scroll, menu zoom TV |

- **Halaman Releases:** [IDLIX-App GitHub Releases](https://github.com/Asadaaaaa/IDLIX-App/releases/tag/v1.4.0)
- **Persyaratan Sistem:** Android 5.0 (Lollipop) atau lebih baru (SDK 21+).
- **Layar Penuh (Immersive):** Navbar atas & bawah telah dihilangkan sehingga tampilan web IDLIX memenuhi layar sepenuhnya.

---

## ✨ Fitur Utama IDLIX-App

### 1. 🌐 Auto Dynamic Domain via GitHub Raw (Tanpa Backend)
- **Tanpa Input Manual:** Pengguna tidak perlu mengetikkan URL apa pun saat membuka aplikasi.
- **Pembaruan Domain Terpusat:** URL dan *allowed host* dimuat langsung dari file [`config.json`](./config.json) pada repositori ini:
  ```
  https://raw.githubusercontent.com/Asadaaaaa/IDLIX-App/main/config.json
  ```
- **Mudah Diganti di GitHub:** Jika domain IDLIX berganti (misalnya ke mirror baru), Anda cukup mengedit `config.json` di GitHub. Semua aplikasi pengguna akan otomatis sinkron ke domain baru saat dibuka.
- **Offline Cache & CDN Backup:** Didukung cache penyimpanan lokal (`SharedPreferences`), mirror CDN jsDelivr, dan domain fallback bawaan.
- **Tombol Update URL Instan:** Tersedia tombol *Sync* di App Bar dan di TV Quick Menu untuk mengecek domain terbaru secara instan.

### 2. 📺 Navigasi Remote D-Pad & Virtual Mouse (Android TV & STB)
- **Kursor Layar Virtual Mouse:**
  - Gerakkan kursor di layar TV menggunakan tombol panah D-Pad remote.
  - Akselerasi dinamis: semakin lama tombol D-Pad ditekan, gerakan kursor bertambah cepat.
  - Auto-scroll otomatis saat kursor mendekati batas atas atau batas bawah layar TV.
  - Tombol **OK / Select / Enter** memicu klik virtual presisi pada link film, episode, dan pemutar video.
- **TV Quick Menu (Tombol Menu / Context Menu):**
  - **Toggle Kursor:** Mengaktifkan atau menyembunyikan kursor virtual.
  - **TV Zoom Scale:** Skala tampilan web (100%, 125%, 150%) untuk kenyamanan membaca di TV layar besar dari jarak sofa.
  - **Aksi Cepat:** Reload halaman, navigasi riwayat mundur (back), dan tombol **Update URL**.
- **Native HTML5 Video Fullscreen:**
  - Pemutar video web (JWPlayer/Video.js) langsung tampil fullscreen landscape di layar TV.

#### 🎮 Pemetaan Tombol Remote TV:
| Tombol Remote | Fungsi di IDLIX-App |
|---|---|
| **D-Pad (Panah Atas/Bawah/Kiri/Kanan)** | Menggerakkan kursor mouse di layar |
| **OK / Center / Select** | Klik elemen website pada posisi kursor |
| **Menu / Context Menu** | Membuka / menutup **TV Quick Menu** |
| **Back / Return** | Navigasi halaman sebelumnya / menutup dialog menu |
| **Media Play / Pause** | Toggle play / pause video yang sedang diputar |
| **Page Up / Down (Channel +/-)** | Scroll cepat halaman web ke atas / ke bawah |

### 3. 📡 Deteksi Video Otomatis & Casting ke Smart TV
- **Deteksi Stream Video:**
  - Mendeteksi elemen `<video>`, iframe pemutar (JWPlayer, Video.js, Plyr), dan request jaringan HLS (`.m3u8`) & MP4.
- **Deteksi Subtitle Otomatis:**
  - Mengambil track subtitle WebVTT (`.vtt`) dan SubRip (`.srt`), termasuk subtitle Bahasa Indonesia dan Inggris.
- **Multi-Protocol Casting:**
  - Mendukung **Google Cast / Chromecast** (Android TV, Google TV, Chromecast Dongle).
  - Mendukung **DLNA / UPnP** (Samsung Tizen TV, LG webOS, Sony, Polytron, Roku, dsb.).
- **Cast Control Bar:**
  - Kontrol pemutaran di layar: Play, Pause, Seek bar, ganti subtitle aktif, dan pengaturan volume.

### 4. 🛡️ Domain Lock & Ad Blocking
- **Domain Lock (Allowlist):** Hanya mengizinkan navigasi pada domain IDLIX aktif beserta subdomainnya (mencegah redirect jebakan).
- **Anti-Popup & Anti-Tab Baru:** Mencegah panggilan `window.open` dan mengubah `target="_blank"` menjadi frame utama.
- **Ad Blocker Bawaan:** Memblokir jaringan iklan video, pop-under, dan banner iklan umum (DoubleClick, Taboola, Outbrain, PopAds, dll.).

---

## 🛠️ Cara Mengganti URL IDLIX di Masa Depan

Jika situs IDLIX berganti domain (misal dari `z2.idlixku.com` ke domain baru):

1. Buka file [`config.json`](https://github.com/Asadaaaaa/IDLIX-App/blob/main/config.json) di repositori GitHub ini.
2. Klik ikon pensil (**Edit this file**).
3. Ubah nilainya, contoh:
   ```json
   {
     "url": "https://z3.idlixbaru.com",
     "allowed_host": "idlixbaru.com",
     "name": "IDLIX",
     "updated_at": "2026-09-12"
   }
   ```
4. Klik **Commit changes...**.
5. **Selesai!** Aplikasi pengguna di TV maupun HP akan otomatis beralih ke domain baru tersebut tanpa perlu compile atau install ulang APK.

---

## 📁 Struktur Project

```
config.json                          <-- Konfigurasi remote JSON URL IDLIX
lib/
├── main.dart                        <-- Titik masuk aplikasi
├── app/
│   └── app.dart                     <-- Konfigurasi root MaterialApp
├── features/
│   ├── cast/                        <-- Fitur Video Detector & Casting
│   │   ├── models/
│   │   │   ├── detected_video.dart
│   │   │   └── detected_subtitle.dart
│   │   ├── services/
│   │   │   ├── cast_manager.dart
│   │   │   └── video_detector_service.dart
│   │   └── presentation/
│   │       └── widgets/
│   │           ├── cast_button.dart
│   │           ├── cast_control_bar.dart
│   │           └── cast_modal_bottom_sheet.dart
│   ├── tv/                          <-- Fitur Android TV & Remote D-Pad
│   │   ├── services/
│   │   │   └── tv_remote_controller.dart
│   │   └── presentation/
│   │       └── widgets/
│   │           ├── tv_virtual_cursor.dart
│   │           └── tv_quick_menu.dart
│   └── webview/                     <-- Fitur WebView & Proteksi Keamanan
│       ├── presentation/
│       │   ├── pages/
│       │   │   └── webview_page.dart
│       │   └── widgets/
│       │       └── loading_overlay.dart
│       ├── services/
│       │   ├── webview_navigation_service.dart
│       │   └── webview_adblock_service.dart
│       └── models/
│           └── webview_config.dart
├── core/
│   ├── constants/
│   │   └── ad_blocklist.dart        <-- Daftar filter domain iklan
│   ├── services/
│   │   ├── remote_config_service.dart <-- Pengambil config JSON dari GitHub
│   │   └── storage_service.dart     <-- Penyimpanan cache SharedPreferences
│   └── utils/
│       ├── url_utils.dart
│       └── domain_utils.dart
```

---

## 🚀 Panduan Kompilasi (Build dari Source)

### Prasyarat:
- Flutter SDK (3.x)
- Android SDK (Platform 34 / 36)
- Java OpenJDK 17+

### 1. Unduh Dependencies:
```bash
flutter pub get
```

### 2. Jalankan Pengujian (Unit Tests):
```bash
flutter test
```

### 3. Build APK Release:
- **Build APK HP / Mobile (`IDLIX`):**
  ```bash
  flutter build apk --release --flavor mobile -t lib/main_mobile.dart
  ```
  File output: `build/app/outputs/flutter-apk/app-mobile-release.apk` (`IDLIX.apk`).

- **Build APK Android TV / STB (`IDLIX TV`):**
  ```bash
  flutter build apk --release --flavor tv -t lib/main_tv.dart
  ```
  File output: `build/app/outputs/flutter-apk/app-tv-release.apk` (`IDLIX-TV.apk`).
