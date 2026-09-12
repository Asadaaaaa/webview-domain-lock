# Flutter WebView App dengan Domain Lock, Ad Blocking, Video Cast & Android TV / STB Remote Support

Aplikasi Flutter browser berbasis WebView dengan sistem proteksi keamanan **Domain Lock**, **Ad Blocking**, kemampuan **Deteksi Video Otomatis & Casting ke Smart TV/Chromecast beserta Subtitle**, serta **Dukungan Penuh Android TV & Android Box (STB)** dengan navigasi remote D-Pad virtual cursor.

Aplikasi ini dirancang khusus untuk:
- Mengunci akses navigasi hanya pada domain utama yang ditentukan beserta subdomainnya (mencegah popup iklan / redirect jebakan pada situs streaming seperti IDLIX).
- Kompatibel langsung pada perangkat **Android TV**, **Google TV**, dan **Android Box / STB** menggunakan navigasi remote TV D-Pad (kursor virtual berakselerasi, auto-scroll di tepi layar, dan klik presisi).
- Mendeteksi stream video (HLS `.m3u8` / `.mp4`) beserta file subtitle (`.vtt` / `.srt`), mendukung pemutaran fullscreen HTML5, dan melakukan casting ke perangkat TV di jaringan lokal.

---

## 📱 Prebuilt APK

File APK release yang sudah dikompilasi tersedia langsung:
- Lokasi di repositori: [`webview-domain-lock.apk`](./webview-domain-lock.apk)
- Siap di-download dan di-install pada perangkat Android (HP/Tablet) dan Android TV / STB Box (Android 5.0+ / SDK 21+).
- Dilengkapi dengan banner Android TV launcher (`LEANBACK_LAUNCHER`).

---

## ✨ Fitur Utama

### 1. 📺 Dukungan Android TV & Android Box (STB) Remote (Baru!)
- **Virtual Mouse (Kursor Layar TV):**
  - Navigasi web bebas repot di layar TV menggunakan D-Pad remote.
  - Akselerasi halus (semakin lama ditekan, kursor bergerak lebih cepat).
  - Auto-scroll dinamis saat kursor menyentuh batas atas/bawah layar TV.
  - Klik virtual presisi menggunakan tombol **OK / Select / Enter** pada remote.
  - Indikator kursor kontras tinggi dengan animasi visual klik.
- **Tombol Remote Terpetakan Penuh:**
  - **D-Pad (Atas / Bawah / Kiri / Kanan):** Gerakkan kursor mouse di layar.
  - **OK / Center / Select:** Klik elemen web yang ditunjuk kursor.
  - **Menu / Context Menu:** Menampilkan **TV Quick Menu** untuk akses cepat.
  - **Back / Return:** Navigasi kembali di browser (kembali halaman sebelumnya) atau menutup dialog/menu.
  - **Media Play / Pause:** Kontrol pemutaran video langsung dari remote.
  - **Page Up / Page Down (Channel +/-):** Scroll halaman secara instan.
- **TV Quick Menu:**
  - Toggle aktif/nonaktif kursor virtual.
  - Pilihan Zoom Layar TV (100%, 125%, 150%) untuk kenyamanan membaca di layar TV besar dari jarak jauh.
  - Reload halaman, navigasi kembali, panel cast video, dan ganti URL.
- **Native HTML5 Video Fullscreen:**
  - Membuka video pemutar web langsung dalam mode layar penuh (landscape) di TV.

### 2. 📡 Deteksi Video & Casting ke Smart TV
- **Deteksi Otomatis Stream Video:**
  - Memindai elemen `<video>`, `<source>`, dan interaksi pemutar media (JWPlayer, Video.js, Plyr, DPlayer).
  - Melakukan intercept network request (`window.fetch` dan `XMLHttpRequest`) untuk menangkap stream HLS (`.m3u8`), MP4, WebM, dsb.
- **Deteksi & Pilihan Subtitle:**
  - Mendeteksi tag `<track>` dan file subtitle (`.vtt`, `.srt`) seperti subtitle bahasa Indonesia (`Indonesian`) dan Inggris (`English`).
  - Memungkinkan pengguna memilih subtitle yang ingin dikirimkan ke perangkat Cast atau memasukkan URL subtitle custom.
- **Multi-Protocol Casting:**
  - **Google Cast / Chromecast** (Google TV, Chromecast Dongle, Android TV, Nest Hub).
  - **DLNA / UPnP** (Samsung Smart TV, LG webOS TV, Sony, Roku, dsb.).
  - **AirPlay** support.
- **Kontrol Pemutaran Lengkap (Cast Control Bar & Sheet):**
  - Tombol Play / Pause / Seek (+10s / -10s / slider progress bar).
  - Sinkronisasi durasi dan posisi pemutaran.
  - Ganti subtitle secara real-time.
  - Pengaturan volume dan pemutusan koneksi (Stop Cast).
- **Floating Action Button & App Bar Badge:**
  - Menampilkan badge jumlah video yang terdeteksi di halaman aktif secara dinamis.
  - Tombol aksi cepat untuk membuka panel Cast.

### 2. 🔒 Domain Lock (Allowlist-Based)
- Hanya mengizinkan navigasi utama pada domain URL yang ditentukan dan subdomainnya (contoh: `idlixku.com`, `z2.idlixku.com`).
- Mencegah teknik bypass domain seperti `idlixku.com.evil.com`.
- Mendukung pemuatan iframe pemutar video pihak ketiga tanpa mengizinkan iframe tersebut membajak jendela utama browser.

### 3. 🛡️ Ad Blocking & Navigation Interception
- Memblokir skema eksternal (`intent://`, `market://`, `whatsapp://`, `mailto:`, `tel:`, dll.).
- Memblokir domain iklan populer (DoubleClick, AdSense, Taboola, Outbrain, PopAds, PopCash, dll.).
- Mencegah pembukaan popup atau window baru (`window.open` dan `target="_blank"` dinetralkan).

### 4. ⚙️ URL Input & Local Storage
- Menampilkan modal input URL saat pertama kali aplikasi dibuka.
- Otomatis menormalisasi URL (menambahkan `https://`).
- Menyimpan URL utama di penyimpanan lokal (`shared_preferences`) dan otomatis memuatnya pada startup berikutnya.
- Menu pengaturan untuk mengganti URL utama kapan saja.

---

## 📁 Struktur Project

```
lib/
├── main.dart
├── app/
│   └── app.dart
├── features/
│   ├── cast/
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
│   ├── tv/
│   │   ├── services/
│   │   │   └── tv_remote_controller.dart
│   │   └── presentation/
│   │       └── widgets/
│   │           ├── tv_virtual_cursor.dart
│   │           └── tv_quick_menu.dart
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
File output build: `build/app/outputs/flutter-apk/app-release.apk`.
