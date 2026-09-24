# Vision Companion

Vision Companion is an assistive vision intelligence mobile application built with Flutter for visually impaired and low-vision users.

The application converts visual surroundings into spoken feedback and provides detailed AI-generated scene descriptions in **English and Hindi**.

---

## Overview

Vision Companion combines real-time computer vision, AI-powered image analysis, accessibility features, and Firebase services into a single mobile application.

The project provides two main vision capabilities:

- **Real-time object detection** using the device camera
- **AI scene analysis** using captured or selected images

The application is designed to keep interaction simple and accessible while maintaining responsive camera performance.

## APK Download

[Download Vision Companion APK](https://drive.google.com/drive/folders/1J-QGfFBOMZ9idKzmGlCJt0eb1-qnyEGc?usp=sharing)

> The APK is provided as a release build for Android.

### Vision API

The originally provided Groq API key was non-functional because it had expired or been revoked.

To maintain reliable vision analysis and detailed scene descriptions, the application uses a **Google Gemini Vision API (Free Tier)** key created through Google AI Studio.

The vision service supports dynamic multi-model candidate rotation using models such as:

- `gemini-1.5-flash-8b`
- `gemini-1.5-flash`
- `gemini-2.0-flash`
- `gemini-2.5-flash`

This rotation helps handle API rate limits such as HTTP `429`.

Groq Vision and local TFLite detection are also retained as fallback options.

---

## Release APK

A pre-built Android release APK can be installed directly on a compatible device.

| Item | Details |
|---|---|
| APK | `build/app/outputs/flutter-apk/app-release.apk` |
| GitHub Releases | `app-release.apk` from the repository Releases section |
| Architecture | Universal — `arm64-v8a`, `armeabi-v7a`, `x86_64` |
| Minimum Android | Android 7.0 (API 24) |
| Target Android | Android 14 (API 34) |

---

## Features

### Real-Time Object Detection

Uses the device camera to continuously detect objects and display bounding boxes around detected items.

Detected objects can also be announced through speech. The live camera feed supports auto-focus and tap-to-announce interaction.

**Technology:** TFLite SSD MobileNet v1, Dart background isolate, Camera YUV420.

### AI Scene Analyzer

Users can capture a new image or select an existing photo. The image is analyzed to generate a detailed natural-language description designed for accessibility and spoken feedback.

**Technology:** Google Gemini Flash, Groq Vision (Llama 3.2), local fallback.

### English and Hindi Accessibility

The interface and spoken announcements support both English and Hindi.

The language can be switched dynamically while using the application.

**Technology:** ARB localization files, ICU plural/select formats, `SemanticsService`.

### Responsive Camera Processing

Real-time object detection runs in a dedicated Dart background worker isolate instead of blocking the main UI thread.

This keeps camera processing separate from UI rendering and helps maintain smooth interaction.

**Technology:** `Isolate.spawn`, `SendPort`, `ReceivePort`.

### Authentication

The application supports:

- Email and password authentication
- Google Sign-In

**Technology:** Firebase Authentication, Google Sign-In.

### Crash Reporting and Analytics

Firebase services are used for application monitoring, crash reporting, and analytics.

**Technology:** Firebase Crashlytics and Firebase Analytics.

---

## Requirements

Before running the project, install the following:

| Requirement | Version / Configuration |
|---|---|
| Flutter SDK | `^3.24.0` or higher |
| Dart SDK | `^3.5.0` or higher |
| Java | JDK 17 |
| Android SDK | API 34 |
| `compileSdkVersion` | 34 |
| `minSdkVersion` | 24 |
| Device | Physical Android device or camera-enabled emulator |

For emulator testing, use an AVD with VirtualScene camera support enabled.

---

## Setup

### 1. Configure Environment Variables

The project uses `flutter_dotenv` for runtime configuration of API keys.

Create a `.env` file in the project root using `.env.example` as the template:

```bash
cp .env.example .env
```

Then add the required keys:

```env
# Google Gemini API Key
# Get a free key from Google AI Studio:
# https://aistudio.google.com/
GEMINI_API_KEY=AIzaSy...your_gemini_api_key_here

# Optional Groq fallback
# https://console.groq.com/
GROQ_API_KEY=gsk_...your_groq_api_key_here
```

### Keep Secrets Out of Git

Never commit API keys or Firebase configuration files containing sensitive project information.

Do not commit:

- `.env`
- `google-services.json`
- `GoogleService-Info.plist`

These files should remain excluded through `.gitignore`.

---

### 2. Configure Firebase

Add the Android Firebase configuration file:

```text
android/app/google-services.json
```

For iOS builds, add:

```text
ios/Runner/GoogleService-Info.plist
```

In the Firebase Console:

1. Enable **Email/Password** authentication.
2. Enable **Google** authentication.
3. Add the required debug and release SHA-1 certificates.

To obtain the signing certificates:

```bash
cd android
./gradlew signingReport
```

### Firestore

Create a Cloud Firestore database and configure authenticated read/write access for the history data.

Example rules:

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{uid}/history/{docId} {
      allow read, write: if request.auth != null 
        && request.auth.uid == uid;
    }
  }
}
```

---

## Install Dependencies

From the project root:

```bash
flutter pub get
```

Generate the English and Hindi localization bindings:

```bash
flutter gen-l10n
```

---

## Run the Application

### Debug Mode

```bash
flutter run
```

### Profile Mode

Profile mode is recommended when testing camera performance and real-time inference:

```bash
flutter run --profile
```

---

## Testing and Static Analysis

Run Flutter static analysis:

```bash
flutter analyze
```

Run the complete test suite:

```bash
flutter test
```

The project currently includes **102 unit/widget tests**.

---

## Build Release APK

Create an optimized release APK with:

```bash
flutter build apk --release
```

The generated APK will be available at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

---

## Documentation

For detailed technical information, refer to [`DOCUMENTATION.md`](DOCUMENTATION.md).

The documentation covers:

- Clean Architecture and feature-first project structure
- Cubit / BLoC state management
- Dependency injection
- Background-isolate object detection
- Multi-tier AI vision fallback system
- TalkBack and screen-reader accessibility patterns
- Known limitations and edge cases

---

## Technology Stack

| Area | Technologies |
|---|---|
| Application | Flutter, Dart |
| Object Detection | TensorFlow Lite, SSD MobileNet v1 |
| AI Vision | Google Gemini Flash, Groq Vision |
| Camera | Flutter Camera, YUV420 |
| Authentication | Firebase Auth, Google Sign-In |
| Database | Cloud Firestore |
| Monitoring | Firebase Crashlytics |
| Analytics | Firebase Analytics |
| Localization | ARB, ICU formats |
| Accessibility | Flutter Semantics, `SemanticsService` |

---

## Project Status

The application includes the core vision, accessibility, authentication, analytics, and Firebase functionality required for the project.

For implementation details and architecture documentation, see [`DOCUMENTATION.md`](DOCUMENTATION.md).
