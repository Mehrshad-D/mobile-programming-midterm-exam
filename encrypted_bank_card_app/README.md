# Encrypted Bank Card App

A Flutter mobile application that securely stores bank card information using **AES encryption**, **SQLite**, and **biometric authentication**. Built with **Material 3** and a modern blue banking-style UI.

> **Educational use only.** This app is designed for learning mobile security concepts. **Never store real banking credentials or production card data.**

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Application ID](#application-id)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Security Model](#security-model)
- [Dependencies](#dependencies)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Building for Release](#building-for-release)
- [Screens](#screens)
- [Platform Notes](#platform-notes)
- [Assets & Branding](#assets--branding)
- [Troubleshooting](#troubleshooting)

---

## Overview

Encrypted Bank Card App demonstrates how to build a secure local-first card wallet on Android (primary target) with:

- Encrypted storage of sensitive card fields
- Biometric / device PIN gate before accessing data
- CRUD operations through a repository layer
- Real-time search over decrypted metadata
- NFC tag reading with optional notes
- Detection and launching of installed Iranian banking/payment apps

The app flow:

```
Native Splash → Flutter Splash (init) → Biometric Lock → Card List → Detail / Add / Edit / Search / NFC / Settings
```

---

## Features

| Area | Description |
|------|-------------|
| **Splash** | Native launch splash + in-app splash with initialization of database, encryption key, and secure storage |
| **Biometric lock** | Fingerprint, Face ID, or device PIN via `local_auth`; authentication cannot be bypassed |
| **Card CRUD** | Create, read, update, delete cards with form validation |
| **Encryption** | `cardNumber`, `cvv2`, `expMonth`, `expYear` encrypted with AES before SQLite write |
| **Masked display** | List shows `1234 **** **** 5678`; CVV never shown in lists |
| **Search** | Real-time search by bank name, card holder name, or last four digits |
| **NFC** | Scan tag ID, technology, and payload; save a note per tag |
| **Banking apps** | Lists installed Iranian banking apps (آپ، تاپ، ایوا، بله، بام، همراه بانک‌ها) and launches them |
| **Settings** | Delete all cards, reset encryption key, logout to biometric screen |
| **UI** | Material 3, blue palette, rounded cards, animated page transitions |

---

## Application ID

| Platform | Identifier |
|----------|------------|
| **Android** `applicationId` / `namespace` | `ir.sharifmp.encrypted_bank_card_app.s401105689_401105912_401170604` |
| **iOS / macOS** bundle identifier | `ir.sharifmp.encrypted_bank_card_app.s401105689_401105912_401170604` |
| **Linux** application ID | `ir.sharifmp.encrypted_bank_card_app.s401105689_401105912_401170604` |

---

## Architecture

The app follows a layered structure. **UI never talks to the database directly.**

```
Screens / Widgets
       ↓
CardRepository  ←→  EncryptionService  ←→  SecureStorageService
       ↓
DatabaseHelper (SQLite: bank_cards.db)
```

**Services** (`AppServices` singleton) wire everything at startup:

- `DatabaseHelper` — SQLite schema and connection
- `EncryptionService` — AES encrypt/decrypt
- `SecureStorageService` — encryption key in `flutter_secure_storage`
- `CardRepository` — encrypt on write, decrypt on read
- `BiometricService` — `local_auth` wrapper
- `NfcService` — NFC scanning and tag notes
- `InstalledAppsService` — native MethodChannel for banking app detection/launch

---

## Project Structure

```
lib/
├── main.dart
├── models/
│   └── bank_card.dart
├── database/
│   └── database_helper.dart
├── repositories/
│   └── card_repository.dart
├── services/
│   ├── app_services.dart
│   ├── encryption_service.dart
│   ├── secure_storage_service.dart
│   ├── biometric_service.dart
│   ├── nfc_service.dart
│   └── installed_apps_service.dart
├── screens/
│   ├── splash_screen.dart
│   ├── biometric_lock_screen.dart
│   ├── card_list_screen.dart
│   ├── add_card_screen.dart
│   ├── edit_card_screen.dart
│   ├── card_detail_screen.dart
│   ├── search_screen.dart
│   ├── nfc_screen.dart
│   ├── installed_apps_screen.dart
│   └── settings_screen.dart
├── widgets/
│   ├── card_tile.dart
│   ├── card_form.dart
│   └── masked_card_widget.dart
└── utils/
    └── app_theme.dart

logo/          # App icon source (1024×1024)
splash/        # Native splash source (1080×1920)
assets/        # Flutter asset copies
android/       # Android native code (MainActivity, manifest, Gradle)
ios/           # iOS project files
```

### Database Schema

**File:** `bank_cards.db`

**Table:** `cards`

| Column | Type | Notes |
|--------|------|-------|
| `id` | INTEGER PK | Auto-increment |
| `cardNumber` | TEXT | Encrypted |
| `cvv2` | TEXT | Encrypted |
| `expMonth` | TEXT | Encrypted |
| `expYear` | TEXT | Encrypted |
| `bankName` | TEXT | Plain text |
| `cardHolderName` | TEXT | Plain text |
| `createdAt` | TEXT | ISO 8601 |
| `updatedAt` | TEXT | ISO 8601 |

**Table:** `nfc_notes` — stores optional notes keyed by NFC tag ID.

---

## Security Model

1. **Encryption key** — Generated automatically on first launch; stored only in `flutter_secure_storage` (never hardcoded).
2. **Sensitive fields** — Encrypted with AES (`encrypt` package) before persistence.
3. **Access control** — Biometric / PIN required on every cold start and after logout.
4. **Display policy** — Masked card numbers in lists; full decrypted values only on the detail screen (toggle visibility).
5. **No logging** — Sensitive values are not written to logs.
6. **Graceful degradation** — NFC, biometrics, and hardware features fail safely with user-facing messages.

### Card Validation

- Card number: exactly **16 digits**
- CVV2: **3–4 digits**
- Expiry: valid month/year, not expired

---

## Dependencies

| Package | Purpose |
|---------|---------|
| `sqflite` | Local SQLite database |
| `path_provider` / `path` | Database file paths |
| `flutter_secure_storage` | Secure encryption key storage |
| `encrypt` / `crypto` | AES encryption |
| `local_auth` | Biometric & device credential auth |
| `nfc_manager` | NFC tag reading |
| `permission_handler` | System permission utilities |
| `intl` | Date formatting |

**Dev dependencies:** `flutter_launcher_icons` (app icon generation)

**Native Android:** Custom `MethodChannel` in `MainActivity.kt` replaces the `installed_apps` pub package for banking app detection (avoids Gradle compatibility issues).

---

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart SDK ^3.11.0)
- Android Studio or VS Code with Flutter extensions
- Android SDK (API 23+)
- For NFC testing: physical Android device with NFC hardware
- For biometrics: emulator with fingerprint enrolled, or a physical device

---

## Getting Started

### 1. Clone and install dependencies

```bash
cd encrypted_bank_card_app
flutter pub get
```

### 2. Run on a connected device or emulator

```bash
flutter run
```

### 3. Clean build (after package name or native changes)

```bash
flutter clean
flutter pub get
flutter run
```

> If you changed the application ID, uninstall any previous build from the device first — Android treats it as a different app.

---

## Building for Release

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

Debug APK:

```bash
flutter build apk --debug
```

---

## Screens

| Screen | Route / Entry | Description |
|--------|---------------|-------------|
| Splash | App start | Initializes services, shows splash artwork |
| Biometric Lock | After splash | Requires authentication |
| Card List | Home | All cards, FAB to add, edit/delete actions |
| Add Card | FAB | Validated form, saves encrypted data |
| Edit Card | Edit button | Loads and updates existing card |
| Card Detail | Tap card | Decrypted values with show/hide toggle |
| Search | App bar icon | Live filter by bank, holder, last 4 digits |
| NFC | App bar icon | Scan tags; graceful message if unavailable |
| Banking Apps | App bar icon | Installed Iranian banking apps; tap to launch |
| Settings | App bar icon | Delete all, reset key, logout, permissions |

---

## Platform Notes

### Android (primary)

- `minSdk`: 23
- Permissions: `USE_BIOMETRIC`, `NFC`, `QUERY_ALL_PACKAGES` (banking app visibility)
- `MainActivity` extends `FlutterFragmentActivity` (required for biometrics)
- Package queries declared in `AndroidManifest.xml` for known banking app package names

### iOS

- Face ID usage description in `Info.plist`
- NFC reader usage description configured
- Biometrics and NFC require physical device for full testing

### Desktop (Windows / Linux / macOS)

- Core Flutter UI may run, but NFC, biometrics, and banking app launch are Android-oriented features.

---

## Assets & Branding

| Asset | Path | Size |
|-------|------|------|
| App logo | `logo/logo.png` | 1024×1024 |
| Splash screen | `splash/splash.png` | 1080×1920 |
| Flutter copies | `assets/logo.png`, `assets/splash.png` | Same as above |

### Regenerate launcher icons

After replacing `logo/logo.png`:

```bash
dart run flutter_launcher_icons
```

Native splash assets are committed under `android/app/src/main/res/` and iOS `LaunchImage` assets. To regenerate splash in the future, temporarily add `flutter_native_splash`, run `dart run flutter_native_splash:create`, then remove the package before building.

---

## Troubleshooting

| Issue | Suggestion |
|-------|------------|
| Gradle / AGP plugin errors | Run `flutter clean`, ensure `android/gradle.properties` has `android.newDsl=false` and `android.builtInKotlin=false` |
| Biometrics not working on emulator | Enroll a fingerprint in emulator settings (Extended Controls → Fingerprint) |
| NFC unavailable | Expected on emulators; use a physical NFC-enabled device |
| Banking apps not listed | App must be installed; package visibility requires manifest `<queries>` entries |
| Decryption fails after key reset | Resetting the encryption key deletes all cards — by design |
| Old app still installed | Uninstall previous package before installing a build with a new application ID |

---

## Test Data Example

Use fictional data only, for example:

| Field | Example |
|-------|---------|
| Card Number | `4111 1111 1111 1111` |
| CVV2 | `123` |
| Expiry | `12 / 2028` |
| Bank Name | `Test Bank` |
| Card Holder | `John Doe` |

---

## License

Educational project — Sharif University of Technology (Mobile Programming course).

---

## Authors

Package ID: `ir.sharifmp.encrypted_bank_card_app.s401105689_401105912_401170604`
