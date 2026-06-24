# Secure Banking App

An educational Flutter application that demonstrates mobile banking security concepts: device integrity checks, app signature verification, OTP authentication, biometric login, secure token storage, and screenshot blocking.

---

## Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Requirements](#requirements)
- [Getting Started](#getting-started)
- [App Flow](#app-flow)
- [Security Features](#security-features)
- [Android Configuration](#android-configuration)
- [Packages](#packages)
- [Mock Data](#mock-data)
- [Testing & Troubleshooting](#testing--troubleshooting)
- [Release Builds](#release-builds)

---

## Features

| Feature | Description |
|--------|-------------|
| **Splash & integrity gate** | Runs device integrity and signature checks on startup |
| **Root blocking** | Blocks app entry if root is detected |
| **Emulator detection** | Detected and shown in Security Report (app still runs for demo) |
| **Login (phone)** | Phone number validation with mock OTP generation |
| **OTP verification** | 6-digit PIN input with simulated SMS delivery & autofill |
| **Biometric auth** | Fingerprint, face, or device PIN via `local_auth` |
| **Secure storage** | JWT token stored with `flutter_secure_storage` |
| **Banking dashboard** | Mock account, balance, and transactions |
| **Screenshot blocking** | `FLAG_SECURE` on OTP, Home, and Security Report screens |
| **Security Report** | Visual report of all security checks |
| **Settings** | Read/delete token, logout |

UI uses **Material 3** with a modern blue banking theme.

---

## Architecture

Clean architecture with three layers:

```
lib/
├── main.dart              # App entry, theme, routing root
├── models/                # Data models
├── services/              # Business logic & platform integration
├── screens/               # Full-page UI
├── widgets/               # Reusable UI components
└── utils/                 # Platform helpers
```

- **Services** handle security, storage, OTP, biometrics, auth, and screenshots.
- **Screens** are responsible for layout and navigation only.
- **Widgets** provide reusable tiles and mixins (e.g. secure screen protection).

---

## Project Structure

```
lib/
├── main.dart
├── models/
│   └── security_report.dart
├── services/
│   ├── auth_service.dart
│   ├── biometric_service.dart
│   ├── otp_service.dart
│   ├── screenshot_service.dart
│   ├── security_service.dart
│   ├── signature_service.dart
│   └── storage_service.dart
├── screens/
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── otp_screen.dart
│   ├── biometric_screen.dart
│   ├── home_screen.dart
│   ├── security_report_screen.dart
│   └── settings_screen.dart
├── widgets/
│   ├── secure_screen_mixin.dart
│   └── security_status_tile.dart
└── utils/
    └── platform_helper.dart
```

### Android native code

```
android/app/src/main/kotlin/com/example/secure_banking_app/
└── MainActivity.kt          # MethodChannel: signature, root, debug, FLAG_SECURE
```

---

## Requirements

- [Flutter SDK](https://docs.flutter.dev/get-started/install) `^3.11.0`
- Dart `^3.11.0`
- Android Studio / Xcode (for mobile targets)
- **Android:** API 23+ (Android 6.0) recommended for biometrics and secure storage
- **Chrome:** supported for UI demo (some security features are Android-only)

---

## Getting Started

### 1. Clone and install dependencies

```bash
cd secure_banking_app
flutter pub get
```

### 2. Run on Android emulator or device

```bash
flutter run
```

### 3. Run on Chrome (web demo)

```bash
flutter run -d chrome
```

> Web/Chrome skips native Android security (signature, `FLAG_SECURE`, biometrics). A **Continue to Home** bypass is provided on the biometric screen.

### 4. Build APK

```bash
flutter build apk --debug
# or
flutter build apk --release
```

---

## App Flow

```
Splash
  │
  ├─ Root detected? ──► Full-screen warning (Persian) — app blocked
  │
  └─ Safe ──► Login
                │
                ▼
              OTP Verification
                │
                ▼
              Biometric Authentication
                │
                ▼
              Home (Dashboard)
                │
                ├─► Security Report
                └─► Settings
```

### Demo login flow

1. Enter any valid phone number (10+ digits), e.g. `09123456789`
2. Tap **Continue** — a Snackbar shows `Demo OTP: xxxxxx`
3. On OTP screen, tap **Simulate SMS Delivery**
4. Tap the **SMS message card** to autofill the code
5. Tap **Verify**
6. On Biometric screen:
   - **Emulator:** set up PIN/fingerprint (see [Troubleshooting](#testing--troubleshooting)) or tap **Skip for Emulator Demo**
   - **Physical device:** use fingerprint, face, or device PIN
7. You reach the **Home** dashboard

---

## Security Features

### 1. Device integrity (`SecurityService`)

| Check | Method |
|-------|--------|
| Root | Native `isDeviceRooted` + path heuristics |
| Emulator | `device_info_plus` (`isPhysicalDevice`, build fingerprint) |
| Debug | `kDebugMode` + native `Debug.isDebuggerConnected()` |

- **`environmentSafe`** = `true` only when **root is NOT detected**
- Emulator is **reported** but does **not** block the app (educational demo)

### 2. App signature (`SignatureService`)

- Computes SHA-256 of the APK signing certificate via native `getAppSignatureSha256`
- Compares against `expectedSignatureSha256` in `lib/services/signature_service.dart`
- **Debug builds:** integrity passes if the hash is retrieved successfully
- **Release builds:** must match the constant exactly

### 3. OTP (`OtpService`)

- Random 6-digit code generated in memory (not sent over network)
- Simulated SMS card for autofill demo
- `sms_autofill` listens for real SMS on physical devices (Google SMS Retriever API)

### 4. JWT token (`AuthService` + `StorageService`)

- Fake JWT generated with the `crypto` package (SHA-256 signature)
- Stored under key `auth_token` in `flutter_secure_storage`
- **Never** uses `SharedPreferences`

### 5. Biometric auth (`BiometricService`)

- Uses `local_auth` with `biometricOnly: false` (allows device PIN/pattern/password)
- Requires `FlutterFragmentActivity` in `MainActivity.kt`

### 6. Screenshot blocking (`ScreenshotService`)

- Sets Android `FLAG_SECURE` via native MethodChannel
- Active on: **OTP**, **Home**, **Security Report**
- Reference-counted so nested navigation (Home → Security Report → back) keeps protection enabled
- Re-applied when the app resumes

---

## Android Configuration

### `AndroidManifest.xml`

Location: `android/app/src/main/AndroidManifest.xml`

```xml
<!-- Biometric authentication -->
<uses-permission android:name="android.permission.USE_BIOMETRIC" />
<uses-permission android:name="android.permission.USE_FINGERPRINT" />
```

- App label: **Secure Banking App**
- Activity: `.MainActivity`
- `sms_autofill` uses the Google SMS Retriever API (no extra manifest receiver required)

### `MainActivity.kt`

Location: `android/app/src/main/kotlin/com/example/secure_banking_app/MainActivity.kt`

| Requirement | Implementation |
|-------------|----------------|
| Biometrics | Extends `FlutterFragmentActivity` (not `FlutterActivity`) |
| Method channel | `com.example.secure_banking_app/security` |
| Signature hash | `getAppSignatureSha256` |
| Root check | `isDeviceRooted` |
| Debug check | `isDebuggerAttached` |
| Screenshot block | `enableScreenshotProtection` / `disableScreenshotProtection` using `FLAG_SECURE` |

> `flutter_windowmanager` was replaced with native `FLAG_SECURE` for compatibility with modern Android Gradle Plugin (AGP 8+).

### `build.gradle.kts` (app module)

Location: `android/app/build.gradle.kts`

| Setting | Value | Reason |
|---------|-------|--------|
| `minSdk` | 23+ | `local_auth`, `flutter_secure_storage`, biometrics |
| `compileSdk` | Flutter default | — |
| Java | 17 | Kotlin / AGP requirement |

If biometrics fail on older API levels, set explicitly:

```kotlin
defaultConfig {
    minSdk = 23
}
```

---

## Packages

| Package | Purpose |
|---------|---------|
| `local_auth` | Fingerprint, face, device PIN |
| `flutter_secure_storage` | Encrypted token storage |
| `device_info_plus` | Emulator / device detection |
| `package_info_plus` | App version in Security Report |
| `sms_autofill` | OTP input & SMS Retriever integration |
| `crypto` | Fake JWT generation (SHA-256) |

---

## Mock Data

All data is hardcoded / generated locally:

| Data | Value / behavior |
|------|------------------|
| Account number | `6037-9912-8845-1203` |
| Balance | `24,850,000 IRR` |
| Transactions | 4 sample credits/debits |
| OTP | Random 6-digit per login |
| JWT | Generated fake token with `crypto` |
| User name | `Demo User` |

No network calls are made.

---

## Testing & Troubleshooting

### Screenshot blocking on emulator

`FLAG_SECURE` **is working** if screen **recording** shows a black screen.

The **emulator toolbar screenshot button** captures the host window (your Mac) and **bypasses** Android security. This is expected.

To test blocking inside the virtual device:

- Press **Power + Volume Down** on the emulated device  
- You should see *"Can't take screenshot due to security policy"* or a black image

On a **physical Android phone**, screenshots are blocked on sensitive screens.

### Biometric auth on emulator

The emulator does **not** use your laptop fingerprint. Set up virtual security:

1. **Settings → Security → Screen lock → PIN** (e.g. `1234`)
2. Emulator toolbar **⋯ → Fingerprint** → add fingerprint → **Touch the sensor**
3. Tap **Authenticate (Fingerprint or PIN)** in the app

Or tap **Skip for Emulator Demo** (educational bypass).

### App blocked at splash (Persian message)

Root was detected. The app blocks entry only for **root**, not emulator.

Message:

> به دلیل ناامن بودن محیط اجرا، امکان استفاده از برنامه وجود ندارد.

Tap **بررسی مجدد** to re-run checks.

### Integrity / tampered in Security Report

- **Debug:** should show valid after a full restart
- **Release:** update `expectedSignatureSha256` in `lib/services/signature_service.dart` with your release signing certificate hash (copy from Security Report)

### Chrome stuck or limited features

Chrome does not support Android-native security. Use an Android emulator or device for the full security demo.

### Gradle / build errors

```bash
flutter clean
flutter pub get
flutter run
```

---

## Release Builds

1. Create a release keystore and configure signing in `android/app/build.gradle.kts`
2. Build: `flutter build apk --release`
3. Install and open **Security Report**
4. Copy the **App Signature** SHA-256 hash
5. Paste it into `expectedSignatureSha256` in `lib/services/signature_service.dart`
6. Rebuild the release APK

---

## Security Report

Accessible from **Home → Security Report**. Shows:

- Root detection
- Emulator detection
- Debug detection
- App signature validity
- Tampered status
- Biometric availability
- Secure storage status
- Screenshot blocking (live status on sensitive screens)

Green check = pass · Red icon = issue detected

---

## Development

```bash
# Analyze
flutter analyze

# Tests
flutter test

# Hot reload (after code changes)
# Press 'r' in the terminal

# Full restart (after native/Android changes)
# Press 'R' in the terminal
```
