# Sensor Dashboard + Live Wallpaper

A production-quality Flutter application that displays live sensor data on a beautiful Material 3 dashboard with a parallax animated background. Built for Android (tested on Pixel 7 emulator and physical devices).

## Features

| Feature | Description |
|---------|-------------|
| **Splash Screen** | App logo, loading animation, initializes permissions, sensors, and theme |
| **Biometric Lock** | Fingerprint, Face ID, or device PIN via `local_auth` |
| **Live Parallax Background** | Accelerometer-driven animated wallpaper on dashboard and detail screens |
| **Sensor Dashboard** | Animated cards with live values; tap to open detail screens |
| **Compass** | Needle dial with heading, degrees, and cardinal direction |
| **GPS Map** | OpenStreetMap tiles (free, no API key) with live location marker |
| **Light Meter** | Lux reading with automatic light/dark theme switching |
| **Step Counter** | Today's steps with live updates |
| **Proximity Sensor** | Near/far detection with color-coded card |
| **Barometer** | Atmospheric pressure and estimated altitude |
| **NFC Reader** | Scan tags; display ID, technology, and payload |
| **Shake Detection** | Shake device to refresh all sensors |
| **Sensor Details** | Full list of all sensors with status icons |
| **Theme Modes** | Light, Dark, and Automatic (light sensor) |

## Screenshots Flow

```
Splash → Biometric Lock → Dashboard → Detail Screens
                              ↓
                    Compass / GPS / Light / Steps
                    Proximity / Barometer / NFC / Details
```

## Project Structure

```
lib/
├── main.dart
├── constants/
│   └── app_assets.dart           # Asset paths and display sizes
├── models/
│   └── sensor_info.dart
├── services/
│   ├── sensor_service.dart       # Central sensor hub (singleton)
│   ├── biometric_service.dart
│   ├── location_service.dart
│   ├── permission_service.dart
│   └── theme_service.dart
├── widgets/
│   ├── app_logo.dart             # Reusable logo widget
│   ├── live_background.dart      # Parallax wallpaper widget
│   └── sensor_card.dart          # Animated dashboard card
└── screens/
    ├── splash_screen.dart
    ├── biometric_lock_screen.dart
    ├── dashboard_screen.dart
    ├── compass_screen.dart
    ├── map_screen.dart
    ├── light_meter_screen.dart
    ├── step_counter_screen.dart
    ├── nfc_screen.dart
    └── sensor_details_screen.dart

assets/
├── logo/
│   └── logo.png                  # 512×512 app logo
└── splash/
    └── splash.png                # 1080×1920 splash background
```

## Requirements

- Flutter SDK ^3.11.0
- Dart ^3.11.0
- Android SDK (minSdk 23, target latest)
- Android device or emulator with Google Play services (for location)

## Getting Started

### 1. Clone and install dependencies

```bash
cd sensor_dashboard_live_wallpaper
flutter pub get
```

### 2. Run on Android

```bash
flutter run
```

For a specific device/emulator:

```bash
flutter devices
flutter run -d <device_id>
```

### 3. Build release APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

## Permissions

The app requests the following Android permissions at runtime:

| Permission | Used For |
|------------|----------|
| `ACCESS_FINE_LOCATION` | GPS map and coordinates |
| `ACCESS_COARSE_LOCATION` | GPS fallback |
| `ACTIVITY_RECOGNITION` | Step counter (Android 10+) |
| `NFC` | NFC tag reading |
| `USE_BIOMETRIC` / `USE_FINGERPRINT` | Biometric authentication |
| `HIGH_SAMPLING_RATE_SENSORS` | Accelerometer, gyroscope |

If a permission is denied, the app **never crashes** — it shows an informative message on the relevant card or screen.

## Dependencies

| Package | Purpose |
|---------|---------|
| `local_auth` | Biometric / PIN authentication |
| `sensors_plus` | Accelerometer, barometer |
| `flutter_compass` | Compass heading |
| `geolocator` | GPS location |
| `flutter_map` + `latlong2` | OpenStreetMap (free, no API key) |
| `permission_handler` | Runtime permission management |
| `light` | Ambient light sensor (lux) |
| `pedometer` | Step counter |
| `nfc_manager` | NFC tag reader |
| `proximity_sensor` | Proximity detection |
| `shake` | Shake gesture detection |
| `device_info_plus` | Android SDK version checks |

## Usage Guide

### Dashboard

- **Tap a card** to open its detail screen
- **Pull down** or tap the **Refresh FAB** to update all sensor values
- **Shake the device** while on the dashboard to trigger a refresh (shows "Shake Detected!" snackbar)
- **Theme menu** (brightness icon in AppBar): Light / Dark / Automatic

### Biometric Lock

On first launch after splash, authenticate with fingerprint, face, or device PIN. Tap **Retry Authentication** if it fails.

> **Emulator tip:** Extended controls → **Fingerprint** → simulate a touch.

### Compass

Shows a rotating needle with heading in degrees and cardinal direction (North, East, etc.). Displays a message if the device has no magnetometer.

### GPS Map

Uses **OpenStreetMap** tiles — no Google Maps API key or billing account required. Requires internet for map tiles.

- Red pin marks your current location
- Bottom card shows latitude/longitude
- **GPS button** (bottom-right) re-centers the map on your position
- **Refresh icon** (AppBar) fetches a new GPS fix

> **Emulator tip:** Extended controls → **Location** → search or drag pin → **Set location**.

### Light Meter

Displays current lux and ambient light level. In **Automatic** theme mode, the app switches between light and dark theme based on ambient light (< 50 lux = dark).

### Step Counter

Shows today's step count with live updates. Requires **Activity recognition** permission on Android 10+.

> **Note:** Most emulators do **not** have step counter hardware. Use a physical device for testing.

### Proximity Sensor

Shows "Object is near" or "Object is far". Dashboard card turns orange when near.

### Barometer

Displays atmospheric pressure (hPa) and estimated altitude derived from pressure.

### NFC Reader

Tap **Start Scan**, then hold an NFC tag near the device.

> **Emulator tip:** Extended controls → **NFC** → simulate a tag. NFC must be enabled on the AVD.

### Sensor Details

Lists every sensor with name, current value, description, update frequency, availability, and status icon.

## Shake Detection

Shake detection uses the accelerometer. When a strong shake is detected:

1. A **"Shake Detected!"** snackbar appears (dashboard only)
2. The refresh icon animates
3. All sensor values refresh

**How to trigger:**

| Environment | Method |
|-------------|--------|
| Physical phone | Firm, quick shake while on the dashboard |
| Emulator | Extended controls → **Virtual sensors** → **Accelerometer** → drag the device sharply in the 3D view |

Current threshold: **1.7× gravity** (tuned for easier triggering on emulator).

## Emulator Testing (Pixel 7)

| Sensor | Emulator Support | How to Test |
|--------|-----------------|-------------|
| Accelerometer | Yes | Virtual sensors → Accelerometer |
| Compass | Limited | May show "not supported" |
| GPS | Yes | Extended controls → Location |
| Light | Limited | May show "not available" |
| Step counter | Usually no | Use physical device |
| Proximity | Limited | May show "not available" |
| Barometer | Limited | May show "not supported" |
| NFC | Yes | Extended controls → NFC |
| Biometric | Yes | Extended controls → Fingerprint |
| Shake | Yes | Virtual sensors → Accelerometer (sharp drag) |

## Error Handling

Every sensor is wrapped in try/catch with graceful fallbacks:

- Unavailable hardware → informative card message, no crash
- Permission denied → clear explanation with retry option
- Stream errors → status updated, app continues running
- Missing data → placeholder values (`—`)

## Android Configuration

### AndroidManifest.xml

Permissions and optional hardware features are declared in:

```
android/app/src/main/AndroidManifest.xml
```

All sensor hardware features are marked `android:required="false"` so the app installs on devices without specific sensors.

### MainActivity.kt

Uses `FlutterFragmentActivity` (required for `local_auth` biometric support):

```kotlin
class MainActivity : FlutterFragmentActivity()
```

### Gradle

- **minSdk:** 23 (biometric authentication)
- **compileSdk / targetSdk:** Managed by Flutter

## Architecture Notes

- **Singleton services** (`SensorService`, `ThemeService`, etc.) manage state via `ChangeNotifier`
- **UI** listens with `ListenableBuilder` for reactive updates
- **LiveBackground** widget reads accelerometer data from `SensorService` and applies smooth, clamped parallax translation
- **ThemeService** supports manual and automatic (light sensor) theme switching
- **PermissionService** centralizes all runtime permission requests

## Troubleshooting

### Map shows tiles but wrong location

1. Set location in emulator: Extended controls → Location → Set location
2. Tap the **GPS button** on the map screen to re-center
3. Grant location permission when prompted

### Map tiles not loading

- Ensure the emulator/device has **internet access**
- OpenStreetMap tiles require a network connection

### Step counter unavailable

- Grant **Activity recognition** permission
- Use a **physical device** — emulators typically lack step hardware

### NFC unavailable

- Enable NFC in emulator extended controls
- On a physical device, enable NFC in system Settings

### Biometric lock fails on emulator

- Set a screen lock (PIN/pattern) on the emulator
- Use Extended controls → Fingerprint to simulate auth

### Shake not detected

- Must be on the **dashboard screen**
- Try a sharper/faster motion
- On emulator, use Virtual sensors → Accelerometer with rapid dragging

## Development

### Analyze code

```bash
flutter analyze
```

### Run tests

```bash
flutter test
```

### Clean build

```bash
flutter clean
flutter pub get
flutter run
```