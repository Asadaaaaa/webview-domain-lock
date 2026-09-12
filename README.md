# 🎬 IDLIX-App — Android TV, STB & Mobile Streaming Client

[![GitHub Release](https://img.shields.io/github/v/release/Asadaaaaa/IDLIX-App?color=red&label=Latest%20Release)](https://github.com/Asadaaaaa/IDLIX-App/releases)
[![Platform](https://img.shields.io/badge/Platform-Android%20TV%20%7C%20STB%20%7C%20Mobile-green)](https://github.com/Asadaaaaa/IDLIX-App)
[![Built with Flutter](https://img.shields.io/badge/Built%20with-Flutter%203-02569B?logo=flutter)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A high-performance streaming browser client built with Flutter, purpose-engineered for **IDLIX**. It runs seamlessly across **Android TV**, **Google TV**, **Android Box (STB)**, as well as **Smartphones & Tablets**.

This app solves the key challenges of web-based streaming:
- 🛡️ **Popup Ads Blocked & Domain Lock:** Blocks intrusive popups, trap redirect tabs, external schemes, and malicious ad networks while strictly locking browsing to legitimate IDLIX domains.
- 🔴 **Netflix-Style Cinematic Splash Screen:** Features a custom cinematic opening animation with an IDLIX ribbon emblem, pulsating radial glow, and smooth zoom transition.
- 🔄 **App Update Detection & In-App Updates:** Automatically detects newer releases from GitHub and executes instant direct APK updates inside the app.
- 🎯 **Circular & Draggable Cast Button:** Floating action button that can be dragged anywhere on the screen without obstructing video controls or subtitles.
- 🖱️ **Remote D-Pad Virtual Mouse:** Smoothly navigate desktop-style websites on TVs using the physical remote control's arrow buttons, accompanied by dynamic acceleration and border auto-scroll.
- 🌐 **Dynamic Domain Sync via GitHub Raw:** Eliminates manual configuration. When IDLIX mirror URLs rotate, updating `config.json` on GitHub automatically syncs across all client apps without requiring app recompilation.
- 📡 **Stream & Subtitle Sniffer with Smart TV Casting:** Intercepts HLS (`.m3u8`) and MP4 video streams alongside Indonesian & English subtitles (`.vtt`, `.srt`), enabling instant casting to **Chromecast / Google Cast** and **DLNA / UPnP Smart TVs**.

---

## 📱 Download APK Releases

IDLIX-App is distributed as **two distinct, optimized APK builds** tailored for specific screen environments:

| Target Platform | App Name | APK Package | Key Highlights |
|---|---|---|---|
| 📱 **Smartphone & Tablet** | **IDLIX** | [`IDLIX.apk`](./IDLIX.apk) | Immersive fullscreen without navigation bars, responsive touch gestures, draggable floating cast button |
| 📺 **Android TV & STB Box** | **IDLIX TV** | [`IDLIX-TV.apk`](./IDLIX-TV.apk) | 16:9 Leanback launcher banner, remote D-Pad virtual cursor, edge auto-scroll, TV zoom scale presets |

- **Releases Page:** [GitHub Releases v1.6.0](https://github.com/Asadaaaaa/IDLIX-App/releases/tag/v1.6.0)
- **Direct Downloads:**
  - 📥 [Download IDLIX.apk (Mobile/Tablet)](https://github.com/Asadaaaaa/IDLIX-App/releases/download/v1.6.0/IDLIX.apk)
  - 📥 [Download IDLIX-TV.apk (Android TV/STB)](https://github.com/Asadaaaaa/IDLIX-App/releases/download/v1.6.0/IDLIX-TV.apk)
- **Minimum Requirements:** Android 5.0 Lollipop or newer (API level 21+).

---

## ✨ Key Features

### 1. 🎬 Netflix-Style Cinematic Splash Screen
- **Cinematic Entrance:** Inspired by premium streaming services, the app opens with a vibrant IDLIX ribbon insignia, pulsating radial ambient glow, and dynamic typography spacing.
- **Seamless Loading:** Maintains user engagement during cold starts while the WebView initializes and loads the portal in the background.
- **Adaptive Dismissal:** Automatically fades out once the web portal is fully rendered.

### 2. 🚀 Automated In-App Update Detection
- **Zero-Friction Updates:** Checks `config.json` on GitHub raw upon startup.
- **In-App Download:** Downloads update packages directly within the app, displaying live byte progress and percentage.
- **Native Package Installer:** Utilizes Android `FileProvider` and native `Intent.ACTION_VIEW` via MethodChannel for one-click installation without third-party app stores or web browsers.

### 3. 🌐 Dynamic Domain Synchronization (No Backend Required)
- **Zero Setup for End-Users:** No URL input fields or manual setups.
- **Centralized Management:** Domain targets and allowlists are fetched dynamically from [`config.json`](./config.json):
  ```
  https://raw.githubusercontent.com/Asadaaaaa/IDLIX-App/main/config.json
  ```
- **Fallback Redundancy:** Includes multi-tier fallbacks: local encrypted cache (`SharedPreferences`), jsDelivr CDN mirrors, and hardcoded default routes.
- **Instant Mirror Updates:** If the streaming domain changes, simply edit `config.json` in this repository. All installations will instantly adapt upon next launch.

### 4. 📺 Android TV & STB Remote D-Pad Navigation
- **Virtual Mouse Cursor:**
  - Control an on-screen cursor using physical remote D-Pad arrow keys.
  - Dynamic acceleration curve: holding down an arrow key gradually speeds up cursor movement.
  - Automated edge scrolling triggers when the cursor nears the top or bottom screen boundaries.
  - Clicking the **OK / Select / Enter** button fires synthesized JavaScript mouse events to activate links, episode selectors, and web players.
- **TV Quick Menu (Remote Menu Button):**
  - Toggle virtual cursor visibility on/off.
  - **TV Zoom Scaling:** Quick presets (100%, 125%, 150%) for clear readability from couch viewing distances.
  - Instant navigation shortcuts: Reload, Back, Forward, and Check Updates.
- **Native Fullscreen Video:** Native HTML5 fullscreen callbacks ensure third-party web video players scale to true 16:9 TV landscape mode.

#### 🎮 Remote Control Button Mapping:
| Remote Key | Action in IDLIX-App |
|---|---|
| **D-Pad (Up / Down / Left / Right)** | Move virtual mouse cursor across the screen |
| **OK / Center / Select** | Click on the element under cursor coordinates |
| **Menu / Context Menu** | Open / close the **TV Quick Menu** |
| **Back / Return** | Browser history back navigation / dismiss modal |
| **Media Play / Pause** | Toggle video playback (web player or active cast session) |
| **Page Up / Down (Channel +/-)** | Rapid page scrolling |

### 5. 📡 Stream & Subtitle Sniffer with Smart TV Casting
- **Stream Interception:** Detects HTML5 `<video>`, `<source>`, JWPlayer, Video.js, Plyr instances, and network XHR/Fetch requests for HLS (`.m3u8`) and MP4 video streams.
- **Subtitle Interception:** Captures `<track>` subtitles, WebVTT (`.vtt`), and SubRip (`.srt`) tracks (Indonesian, English, etc.).
- **Multi-Protocol Casting:**
  - **Google Cast / Chromecast** (Android TV, Google TV, Chromecast dongles).
  - **DLNA / UPnP** (Samsung Tizen, LG webOS, Sony, Roku, etc.).
- **On-Screen Cast Control Bar:** Play, Pause, Seek slider, Volume adjustment, and live Subtitle selection.

### 6. 🛡️ Domain Lock & "Popup Ads Blocked" Protection
- **Strict Allowlist (Domain Lock):** Restricts navigation to the verified IDLIX domain and its authenticated subdomains.
- **Popup & Tab Hijacking Blocker:** Neutralizes `window.open()` exploits and rewrites `target="_blank"` anchors to protect the main browsing session.
- **Network Ad Blocker:** Filters out known ad networks, analytics trackers, pop-unders, and scam domains.
- **Intuitive Feedback:** Blocked malicious redirect attempts trigger a clean **"Popup Ads Blocked"** shield notification.

---

## 🛠️ How to Update the IDLIX Domain in the Future

Whenever IDLIX rotates its official mirror domain:

1. Open [`config.json`](https://github.com/Asadaaaaa/IDLIX-App/blob/main/config.json) in this repository.
2. Click the pencil icon (**Edit this file**).
3. Update the fields accordingly:
   ```json
   {
     "url": "https://new-mirror.idlixku.com",
     "allowed_host": "idlixku.com",
     "name": "IDLIX",
     "updated_at": "2026-09-12",
     "latest_version": "1.6.0",
     "latest_version_code": 16,
     "release_notes": "Domain updated to the latest mirror.",
     "mobile_apk_url": "https://github.com/Asadaaaaa/IDLIX-App/releases/download/v1.6.0/IDLIX.apk",
     "tv_apk_url": "https://github.com/Asadaaaaa/IDLIX-App/releases/download/v1.6.0/IDLIX-TV.apk"
   }
   ```
4. Commit your changes to the `main` branch.
5. **Done!** Every user device will automatically connect to the new domain upon launch.

---

## 📁 Repository Structure

```
.
├── config.json                          # Central dynamic configuration & update metadata
├── IDLIX.apk                            # Prebuilt release APK for Mobile / Tablet
├── IDLIX-TV.apk                         # Prebuilt release APK for Android TV / STB
├── android/                             # Native Android configuration & Leanback setup
│   └── app/src/main/
│       ├── AndroidManifest.xml          # Permissions, FileProvider, Leanback banner
│       ├── res/xml/file_paths.xml       # FileProvider path mapping for APK installation
│       └── kotlin/.../MainActivity.kt   # Native MethodChannel for In-App APK installation
├── lib/
│   ├── main.dart                        # Default entry point
│   ├── main_mobile.dart                 # Mobile flavor entry point (IDLIX)
│   ├── main_tv.dart                     # Android TV flavor entry point (IDLIX TV)
│   ├── app/
│   │   └── app.dart                     # MaterialApp root configuration
│   ├── core/                            # Shared utilities, domain locking, remote config
│   │   ├── services/
│   │   │   ├── remote_config_service.dart
│   │   │   └── storage_service.dart
│   │   └── utils/
│   │       ├── domain_utils.dart
│   │       └── url_utils.dart
│   └── features/
│       ├── cast/                        # Video stream & subtitle sniffer, casting engine
│       │   ├── models/
│       │   ├── services/
│       │   └── presentation/widgets/
│       ├── tv/                          # Android TV remote controller & virtual mouse cursor
│       │   ├── services/
│       │   └── presentation/widgets/
│       ├── update/                      # In-app update detection, downloader & dialog
│       │   ├── models/
│       │   ├── services/
│       │   └── presentation/widgets/
│       └── webview/                     # WebView core, navigation delegate & splash screen
│           └── presentation/widgets/
│               └── idlix_splash_screen.dart # Netflix-style cinematic splashscreen
└── test/                                # Automated unit test suites
```

---

## 💻 Building From Source

### Prerequisites
- Flutter SDK 3.13+
- Android SDK with Platform Tools (API 21+)
- JDK 17

### Build Commands
```bash
# Clone the repository
git clone https://github.com/Asadaaaaa/IDLIX-App.git
cd IDLIX-App

# Install Flutter dependencies
flutter pub get

# Run automated tests
flutter test

# Build Mobile Release APK (IDLIX.apk)
flutter build apk --release --flavor mobile -t lib/main_mobile.dart

# Build Android TV Release APK (IDLIX-TV.apk)
flutter build apk --release --flavor tv -t lib/main_tv.dart
```

---

## 📄 License
This project is open-source under the [MIT License](LICENSE).
