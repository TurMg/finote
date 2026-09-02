<div align="center">

  # 📱 Finote
  ### *Track Smart. Save More.*

  [![Flutter](https://img.shields.io/badge/Flutter-%5E3.5.4-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
  [![Dart](https://img.shields.io/badge/Dart-%5E3.5.4-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
  [![Architecture](https://img.shields.io/badge/Architecture-Clean%20%2F%20BLoC-ff69b4?style=for-the-badge)](https://bloclibrary.dev)
  [![Database](https://img.shields.io/badge/Database-Isar%20NoSQL-blueviolet?style=for-the-badge)](https://isar.dev)
  [![Tests](https://img.shields.io/badge/Tests-19%2F19%20Passed-success?style=for-the-badge)](https://github.com)

</div>

---

## 📌 Tentang Finote

**Finote** adalah aplikasi manajemen keuangan pribadi modern berbasis Android & iOS yang dirancang untuk kecepatan, kemudahan, dan reliabilitas tinggi. Dengan pendekatan *Offline-First*, pengguna dapat mencatat transaksi keuangan secara instan lewat input manual, **perintah suara (Voice Input)**, hingga **pemindaian bukti struk (OCR Scanner)**.

Data keuangan tersimpan dengan aman secara lokal menggunakan Isar NoSQL DB dan tersinkronisasi otomatis 2 arah (*Two-Way Merge Sync*) ke Google Sheets pengguna di latar belakang.

---

## 📥 Download Aplikasi

| Platform | Berkas / Link Download | Keterangan |
| :--- | :--- | :--- |
| 🤖 **Android APK** | [Download APK Release (`.apk`)](../../releases/latest) | APK Ter-optimasi (`Finote.apk` ~34 MB) |
---

## 🌟 Fitur Unggulan

- ⚡ **Offline-First & Fast Execution**: Menggunakan Isar NoSQL Database untuk pencatatan dan pencarian data berkecepatan 1–5 ms.
- 🔮 **Antarmuka Liquid & Micro-Animations**: Transisi perpindahan halaman Material 3 (*FadeThrough*), indikator opsi kapsul meluncur (*Sliding Segmented Control*), animasi angka memutar (*Animated Counter Text*), *Skeleton Shimmer Loading*, dan sentuhan getaran fisik (*Haptic Feedback*).
- 🎙️ **Input Transaksi Suara Pintar (Voice Input)**: Mengenali perintah suara dalam Bahasa Indonesia secara otomatis menggunakan *Smart Indonesian Keyword Thesaurus (13 Domain Keuangan)*.
- 📷 **Pemindai Struk OCR (Receipt Scanner)**: Mengekstrak total nominal dari foto struk belanja menggunakan Google ML-Kit Text Recognition & Spatial Candidate Scoring.
- 🔄 **Sinkronisasi Otomatis 2 Arah (Google Sheets Sync)**: Fitur *Cloud Sync* pintar yang melakukan merge data tanpa mengganggu antarmuka pengguna (*non-blocking background sync*).
- 🏷️ **Kelola Kategori Fleksibel**: Dukungan ikon Vector Material, Emoji, hingga foto custom dari galeri HP.
- 🎨 **Antarmuka Premium & Kustomisasi**: Palet warna hangat khas (*Almond Cream & Espresso Charcoal*), kustomisasi profil, dan indikator tipe dinamis.

---

## 🏗️ Arsitektur & Teknologi

Finote dibangun mematuhi prinsip **CLEAN Architecture** dan **DRY (Don't Repeat Yourself)**:

```
lib/
├── core/                  # Color palette, routes, services (Sync, Settings, Google Sheets), reusable widgets (Shimmer, Counter, Segmented)
├── features/
│   ├── category/          # Feature Kelola Kategori (Data, Domain, Presentation - BLoC)
│   ├── profile/           # Feature Profile & Pengaturan Pengguna
│   └── transaction/       # Feature Utama Transaksi, OCR, & Voice Input (BLoC)
```

### Tech Stack Utama:
- **Framework**: Flutter (Dart SDK ^3.5.4)
- **State Management**: `flutter_bloc`
- **Local Database**: `isar` & `isar_flutter_libs`
- **OCR Engine**: `google_mlkit_text_recognition`
- **Speech Recognition**: `speech_to_text`
- **Cloud Backup**: `googleapis` & `google_sign_in` (Google Sheets v4 & Drive v3 API)
- **Navigation**: `go_router` (Material 3 Page Transitions)
- **Dependency Injection**: `get_it`

---

## 🚀 Cara Menjalankan Project

### Prasyarat
- Flutter SDK v3.24.0 atau lebih baru
- Android Studio / VS Code dengan Flutter extension
- HP Android fisik / Emulator

### Langkah-langkah

1. **Klon Repositori**:
   ```bash
   git clone https://github.com/username/finote.git
   cd finote
   ```

2. **Install Dependensi**:
   ```bash
   flutter pub get
   ```

3. **Jalankan Aplikasi**:
   ```bash
   flutter run
   ```

4. **Build APK Rilis & App Bundle**:
   ```bash
   flutter build apk --release --split-per-abi
   flutter build appbundle
   ```
   *File APK rilis dapat ditemukan di `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` dan App Bundle di `build/app/outputs/bundle/release/app-release.aab`.*

---

## 🧪 Pengujian Otomatis (Automated Testing)

Finote dilengkapi dengan *unit test suite* yang mencakup aturan auto-sync, parsing nominal rupiah, preprocessing gambar OCR, penyimpan username, dan penentuan kata kunci voice.

Jalankan pengujian unit dengan perintah:
```bash
flutter test
```

---

<div align="center">
  <sub>Developed with ❤️ for Smart Financial Tracking.</sub>
</div>
