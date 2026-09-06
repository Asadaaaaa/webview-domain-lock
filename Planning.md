Flutter WebView App dengan Domain Lock dan Ad Blocking

1. Tujuan Aplikasi

Buat aplikasi Flutter berupa browser sederhana berbasis WebView.

Aplikasi hanya digunakan untuk membuka satu URL website utama yang ditentukan oleh user saat aplikasi pertama kali dibuka.

Aplikasi harus membatasi WebView agar:

- Tidak membuka website lain di luar domain URL utama.
- Tidak mengikuti redirect ke domain lain.
- Tidak membuka aplikasi eksternal.
- Tidak membuka browser eksternal.
- Memblokir popup atau window baru.
- Memblokir iklan dan resource dari domain iklan yang diketahui.
- Menggunakan sistem allowlist untuk domain yang diperbolehkan.

---

2. Tech Stack

Gunakan:

- Flutter
- Dart
- WebView Flutter yang mendukung kontrol navigation dan request interception sesuai kebutuhan
- Local storage untuk menyimpan URL utama
- Android sebagai target utama

Gunakan struktur kode yang rapi dan mudah dikembangkan.

---

3. Application Flow

Saat Aplikasi Dibuka

APP START
    ↓
Cek apakah URL sudah tersimpan
    ↓
Apakah URL tersedia?
    │
    ├── TIDAK
    │     ↓
    │  Tampilkan Modal Input URL
    │     ↓
    │  User memasukkan URL
    │     ↓
    │  Validasi URL
    │     ↓
    │  Simpan URL secara lokal
    │     ↓
    │  Extract hostname/domain
    │     ↓
    │  Buka URL di WebView
    │
    └── YA
          ↓
    Load URL yang tersimpan
          ↓
    Extract hostname/domain
          ↓
    Buka WebView

---

4. URL Input Modal

Saat belum terdapat URL yang tersimpan, tampilkan modal atau dialog.

Komponen:

- Text input untuk URL.
- Tombol "Open".
- Validasi URL sebelum disimpan.

Contoh:

┌─────────────────────────────┐
│         Open Website        │
│                             │
│  Enter website URL          │
│                             │
│  [ https://example.com    ] │
│                             │
│             [ Open ]        │
└─────────────────────────────┘

URL harus valid.

Contoh URL valid:

https://example.com
http://example.com
https://www.example.com

Jika user memasukkan URL tanpa protocol, normalisasi dengan menambahkan:

https://

Contoh:

example.com

Menjadi:

https://example.com

Setelah URL valid:

1. Simpan URL utama ke local storage.
2. Extract hostname dari URL.
3. Gunakan hostname sebagai allowed domain.
4. Load URL ke WebView.

---

5. Local Storage

Simpan minimal data berikut:

mainUrl
allowedHost

Contoh:

mainUrl:
https://example.com

allowedHost:
example.com

Saat aplikasi dibuka kembali, gunakan data tersebut secara otomatis tanpa meminta input ulang.

---

6. Domain Allowlist

Aplikasi harus menggunakan pendekatan allowlist, bukan hanya blacklist.

Misalnya URL utama:

https://example.com

Hostname:

example.com

Maka URL yang diperbolehkan:

https://example.com
https://example.com/article
https://example.com/login
https://www.example.com
https://api.example.com

Subdomain dapat diizinkan.

Aturan validasi domain:

uri.host == allowedHost

atau:

uri.host.endsWith('.$allowedHost')

Dengan demikian:

example.com
www.example.com
api.example.com
cdn.example.com

dapat diakses.

Tetapi domain berikut harus diblok:

google.com
youtube.com
facebook.com
doubleclick.net
ads.example.com
example-other.com
example.com.evilsite.com

Penting: jangan menggunakan pengecekan sederhana seperti:

url.contains("example.com")

karena dapat menyebabkan bypass seperti:

example.com.evilsite.com

Gunakan parsing hostname melalui "Uri".

---

7. Navigation Blocking

Setiap request navigasi harus diperiksa sebelum WebView membuka URL.

Flow:

USER / WEBSITE REQUESTS URL
            ↓
       Parse URI
            ↓
      Check Scheme
            ↓
      HTTP / HTTPS?
       │         │
      NO        YES
       ↓         ↓
    BLOCK    Check Host
                  ↓
           Allowed Domain?
              │        │
             NO       YES
              ↓        ↓
            BLOCK    ALLOW

Contoh:

URL| Result
"https://example.com"| Allow
"https://example.com/news"| Allow
"https://api.example.com/data"| Allow
"https://google.com"| Block
"https://ads.google.com"| Block
"https://youtube.com"| Block
"https://evil.com"| Block

---

8. Redirect Blocking

Redirect dari website utama juga harus diperiksa.

Contoh:

https://example.com
        ↓
redirect
        ↓
https://ads-network.com/click

Karena:

ads-network.com

bukan allowed domain, maka redirect harus dibatalkan.

Result:

BLOCK

Redirect hanya boleh dilakukan jika destination URL masih berada dalam domain:

example.com

atau subdomainnya yang diperbolehkan.

Contoh:

https://example.com/login
        ↓
https://example.com/dashboard

Result:

ALLOW

---

9. Block External Application

Aplikasi tidak boleh membuka aplikasi lain.

Gunakan pendekatan:

«Hanya scheme "http" dan "https" yang diperbolehkan.»

Semua scheme lainnya harus diblok.

Contoh scheme yang harus diblok:

intent://
market://
whatsapp://
tg://
spotify://
mailto:
tel:
sms:
geo:

Contoh:

whatsapp://send?phone=123

Result:

BLOCK

Contoh:

intent://scan/#Intent;scheme=zxing;package=...

Result:

BLOCK

Contoh logic:

if (uri.scheme != 'http' && uri.scheme != 'https') {
  block();
}

Jangan meneruskan URL tersebut ke aplikasi eksternal.

Jangan menggunakan:

url_launcher

untuk membuka URL eksternal.

---

10. External Browser Blocking

Semua link harus tetap diproses di dalam aplikasi.

Jika URL bukan bagian dari allowed domain:

BLOCK

Jangan:

- Membuka Chrome.
- Membuka browser default.
- Membuka Custom Tabs.
- Membuka aplikasi eksternal.

Contoh:

User klik:
https://google.com

Result:

Tidak membuka Chrome
Tidak membuka browser
Tidak membuka Google
Tetap berada di aplikasi

---

11. Popup dan New Window Blocking

Website dapat mencoba membuka popup melalui:

window.open()

atau target:

_blank

Semua new window atau popup yang tidak memenuhi aturan domain harus diblok.

Secara default, aplikasi harus mencegah pembukaan window baru yang dapat membuka:

- Website iklan.
- Popunder.
- Popup.
- Browser eksternal.
- Aplikasi eksternal.

Jika implementasi WebView menyediakan callback untuk create window atau popup, intercept callback tersebut dan lakukan validasi domain.

Jika URL popup tidak termasuk allowed domain:

BLOCK

Jangan membuat WebView baru secara otomatis.

---

12. Ad Blocking

Aplikasi harus memiliki layer ad blocking tambahan.

Navigation blocking saja tidak cukup.

Contoh halaman:

https://example.com/article

Halaman tersebut dapat memuat resource:

https://doubleclick.net/ad.js
https://googlesyndication.com/banner
https://ads-network.com/script.js

Walaupun halaman utama masih berada di:

example.com

resource tersebut tetap merupakan request eksternal.

Jika WebView package yang digunakan mendukung request interception, request harus diperiksa.

---

13. Ad Domain Blocklist

Buat file atau konfigurasi khusus untuk daftar domain iklan.

Contoh:

doubleclick.net
googlesyndication.com
googleadservices.com
adservice.google.com
adsystem.com
taboola.com
outbrain.com

Struktur harus mudah ditambahkan.

Contoh konsep:

ad_blocklist.dart

Berisi daftar domain:

final Set<String> adBlockedDomains = {
  'doubleclick.net',
  'googlesyndication.com',
  'googleadservices.com',
  'adservice.google.com',
  'adsystem.com',
  'taboola.com',
  'outbrain.com',
};

Pengecekan domain harus mendukung subdomain.

Contoh:

securepubads.g.doubleclick.net

harus dianggap termasuk:

doubleclick.net

---

14. Request Filtering

Setiap request resource harus melalui aturan berikut:

REQUEST
   ↓
Check URL Scheme
   ↓
HTTP/HTTPS?
   │
   ├── NO → BLOCK
   │
   └── YES
          ↓
    Check Ad Blocklist
          │
          ├── MATCH → BLOCK
          │
          └── NO
                 ↓
         Continue Request

Contoh:

https://example.com/main.js

Result:

ALLOW

Contoh:

https://securepubads.g.doubleclick.net/tag/js/gpt.js

Result:

BLOCK

---

15. Blocking Prioritas

Gunakan urutan pemeriksaan berikut.

Priority 1 — Block Invalid / External Scheme

intent://
market://
whatsapp://
mailto:
tel:
sms:
geo:
spotify://

Result:

BLOCK

Priority 2 — Block Ad Domains

Jika request menuju domain yang terdapat dalam ad blocklist:

BLOCK

Priority 3 — Navigation Domain Check

Untuk top-level navigation:

Allowed domain → ALLOW
Other domain → BLOCK

---

16. Back Navigation

Tombol back Android harus memiliki behavior berikut:

Ada WebView history?
        │
       YES
        ↓
WebView Go Back
        │
       NO
        ↓
Close App / Default Back Behavior

Jika WebView sebelumnya memiliki URL dari allowed domain, user dapat kembali seperti browser biasa.

Namun tetap jangan pernah membuka URL eksternal yang sebelumnya diblok.

---

17. Loading State

Saat website sedang dimuat, tampilkan loading indicator.

Contoh:

┌─────────────────────────────┐
│                             │
│                             │
│          Loading...         │
│            ⟳                │
│                             │
│                             │
└─────────────────────────────┘

Loading harus hilang setelah halaman selesai dimuat.

Jika terjadi error, tampilkan error state sederhana.

---

18. Error Handling

Tangani kondisi berikut:

URL Tidak Valid

Please enter a valid URL.

Website Tidak Dapat Dimuat

Tampilkan:

Unable to load website.

Sediakan tombol:

Retry

Navigation Blocked

Jika user atau website mencoba membuka domain lain, jangan crash.

Cukup:

Cancel navigation.

Tidak perlu membuka browser eksternal.

---

19. URL Settings

Sediakan menu sederhana untuk mengganti URL utama.

Contoh:

Settings
    ↓
Current URL:
https://example.com

[ Change URL ]

Saat URL diganti:

1. Validasi URL baru.
2. Update local storage.
3. Update "mainUrl".
4. Extract "allowedHost" baru.
5. Clear WebView state jika diperlukan.
6. Reload menggunakan URL baru.

---

20. Struktur Project

Gunakan struktur sederhana seperti berikut:

lib/
├── main.dart
│
├── app/
│   └── app.dart
│
├── features/
│   └── webview/
│       ├── presentation/
│       │   ├── pages/
│       │   │   └── webview_page.dart
│       │   │
│       │   └── widgets/
│       │       ├── url_input_dialog.dart
│       │       └── loading_overlay.dart
│       │
│       ├── services/
│       │   ├── webview_navigation_service.dart
│       │   └── webview_adblock_service.dart
│       │
│       └── models/
│           └── webview_config.dart
│
├── core/
│   ├── constants/
│   │   └── ad_blocklist.dart
│   │
│   ├── services/
│   │   └── storage_service.dart
│   │
│   └── utils/
│       ├── url_utils.dart
│       └── domain_utils.dart

Jangan membuat arsitektur terlalu kompleks karena aplikasi ini sederhana.

---

21. Domain Utility

Buat utility untuk:

- Normalize URL.
- Validate URL.
- Extract hostname.
- Check allowed domain.
- Check subdomain.
- Check blocked ad domain.

Contoh fungsi:

normalizeUrl()
isValidUrl()
extractHost()
isAllowedDomain()
isBlockedAdDomain()

Pengecekan domain harus aman.

Contoh:

Allowed host:

example.com

URL:

https://example.com.evil.com

Harus menghasilkan:

false

URL:

https://sub.example.com

Harus menghasilkan:

true

---

22. WebView Rules Summary

Gunakan aturan berikut:

┌──────────────────────────────────────────┐
│              WEBVIEW REQUEST             │
└─────────────────────┬────────────────────┘
                      ↓
             Parse URL safely
                      ↓
          ┌─────────────────────┐
          │ HTTP / HTTPS only?  │
          └───────┬───────┬─────┘
                 NO       YES
                  ↓         ↓
                BLOCK   Is Ad Domain?
                           │
                    YES ───┤─── NO
                    ↓             ↓
                  BLOCK    Is Navigation?
                                 │
                                 ↓
                        Allowed Domain?
                           │         │
                         NO          YES
                          ↓            ↓
                        BLOCK        ALLOW

---

23. Security Requirements

Wajib:

- Jangan membuka aplikasi eksternal.
- Jangan menggunakan external browser fallback.
- Jangan mengizinkan scheme selain HTTP/HTTPS.
- Jangan menggunakan "contains()" untuk validasi domain.
- Gunakan hostname dari parsed URI.
- Cegah bypass domain seperti:

example.com.evil.com

- Intercept navigation sebelum URL dibuka.
- Intercept popup/new window jika didukung package.
- Block domain iklan pada request level jika package mendukung.

---

24. Expected Final Behavior

Contoh konfigurasi:

Main URL:
https://example.com

User membuka:

https://example.com/article/1

Result:

ALLOW

Website redirect ke:

https://example.com/login

Result:

ALLOW

Website redirect ke:

https://ads.google.com/click

Result:

BLOCK

Website membuka:

https://google.com

Result:

BLOCK

Website mencoba membuka:

whatsapp://send?phone=123

Result:

BLOCK

Website mencoba membuka:

intent://something

Result:

BLOCK

Website memuat:

https://securepubads.g.doubleclick.net/tag.js

Result:

BLOCK

Website membuka popup:

https://advertisement-domain.com

Result:

BLOCK

---

25. Final Requirements

Implementasikan aplikasi Flutter yang:

- Menampilkan modal input URL saat pertama kali aplikasi dibuka.
- Menyimpan URL utama secara lokal.
- Otomatis membuka URL tersimpan pada startup berikutnya.
- Menggunakan WebView.
- Mengizinkan hanya domain utama dan subdomainnya.
- Memblokir navigation ke domain lain.
- Memblokir redirect ke domain lain.
- Memblokir popup dan new window.
- Memblokir scheme selain HTTP dan HTTPS.
- Tidak membuka browser eksternal.
- Tidak membuka aplikasi eksternal.
- Memiliki ad blocklist.
- Memblokir request iklan jika WebView implementation mendukung request interception.
- Memiliki loading state.
- Memiliki error handling.
- Memiliki tombol atau halaman settings untuk mengganti URL utama.
- Memiliki kode yang clean, modular, dan mudah dikembangkan.
- Jangan membuat backend karena seluruh aplikasi berjalan secara lokal.
- Jangan menambahkan fitur yang tidak disebutkan dalam spesifikasi ini.
