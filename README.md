# Pauza — Digital Wellbeing & Focus App

Pauza is a Flutter mobile app (iOS + Android) for modes-based digital wellbeing. Users create **Modes** — named profiles that block or restrict selected apps on their device for a set duration or schedule. The app uses native platform APIs (Android Accessibility Service, iOS Screen Time / Family Controls) via the `pauza_screen_time` plugin to enforce restrictions at the OS level.

## Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Configuration](#configuration)
- [Running Tests](#running-tests)
- [Code Quality](#code-quality)
- [Building for Production](#building-for-production)
- [Project Structure](#project-structure)
- [Architecture](#architecture)
- [Localization](#localization)
- [Makefile Reference](#makefile-reference)
- [Troubleshooting](#troubleshooting)

## Features

- **Modes** — create and schedule app-blocking sessions with custom app lists
- **Focus streaks & stats** — track usage patterns and streaks over time
- **Friends & leaderboards** — compare focus scores with friends
- **NFC / QR unlock** — physical unlock tokens to end a session
- **Emergency stop** — configurable override for urgent situations
- **Sync** — offline-first (SQLite) with optional server sync for backup and social features
- **Subscriptions** — premium entitlements via RevenueCat
- **Localization** — English, Russian, Uzbek (Latin), Uzbek (Cyrillic)

## Prerequisites

### Required Tools

| Tool | Version | Install |
|------|---------|---------|
| Flutter SDK | >= 3.41.x (Dart >= 3.9.2) | [flutter.dev/docs/get-started/install](https://docs.flutter.dev/get-started/install) |
| Xcode (iOS) | >= 16.x | Mac App Store |
| Android Studio / SDK | >= API 26 | [developer.android.com/studio](https://developer.android.com/studio) |
| CocoaPods (iOS) | >= 1.15 | `sudo gem install cocoapods` |
| Make | system default | Pre-installed on macOS/Linux |
| Firebase CLI | latest | `npm install -g firebase-tools` |

### Verify your environment

```bash
flutter doctor
```

All checks should pass (or show only non-blocking warnings). Fix any issues Flutter Doctor reports before continuing.

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/pauzaa/pauza-app.git
cd pauza-app
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Generate code (localization, assets, build_runner)

```bash
make generate
```

This runs, in order:

1. `flutter pub get` — install dependencies
2. `flutter gen-l10n` — generate localization classes from ARB files
3. `dart format` — format the codebase
4. `fluttergen` — generate typed asset references
5. `build_runner build` — run source generation (adapters, etc.)

### 4. Run the app

```bash
# List connected devices / emulators
flutter devices

# Run the app
flutter run

# Run on a specific device
flutter run -d <device-id>
```

> **Note:** App restriction features (blocking) require a **physical device**. Emulators/simulators do not support the Accessibility Service (Android) or Family Controls (iOS) APIs.

#### iOS — additional setup

Before the first iOS run, install CocoaPods dependencies:

```bash
cd ios
pod install
cd ..
```

The `pauza_screen_time` plugin requires the **Family Controls** capability and an Apple Developer account with Screen Time entitlements. Ensure your provisioning profile includes `com.apple.developer.family-controls`.

#### Android — additional setup

Enable **Developer Options** on the device and grant Accessibility Service permission to Pauza after first launch. The app will prompt for required permissions on startup.

## Configuration

Environment config lives in `config/`:

| File | Purpose |
|------|---------|
| `config/prod.json` | Production API base URL and settings |
| `config/test.json` | Test / staging overrides |

Config is loaded at runtime via [AppFuse](https://pub.dev/packages/appfuse). The active environment can be switched through the AppFuse debug menu (shake gesture or long-press on the splash screen in debug builds). In release builds, the production config is used automatically.

## Running Tests

### Unit and widget tests

```bash
# Run all unit and widget tests with coverage
make test

# Run a specific test file
flutter test test/path/to/test_file.dart

# Run a specific test by name
flutter test --name "test name"
```

### Integration tests

Requires a connected physical device or emulator:

```bash
make integration
```

### Coverage report

Generate an HTML coverage report:

```bash
make coverage
```

This runs tests with coverage collection, strips generated files from the report, and produces an `lcov.info` file. To view as HTML, use `genhtml`:

```bash
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Code Quality

```bash
# Format code (120-char line width)
make format

# Static analysis (format check + strict lint — warnings are errors)
make analyze

# Auto-fix lint issues
dart fix --apply lib

# Full pipeline: generate + format + analyze + test
make all
```

Run `make analyze` before every commit. The CI pipeline enforces zero warnings/errors.

## Building for Production

```bash
# Android APK (release)
make build-android

# iOS (release — requires Xcode + provisioning)
make build-ios
```

## Project Structure

```
pauza-app/
├── lib/
│   └── src/
│       ├── app/              # App shell, root BLoC scope, DI wiring
│       ├── core/             # API client, SQLite DB, routing, connectivity
│       └── features/         # Feature modules (see below)
├── test/                     # Unit and widget tests (mirrors lib/)
├── integration_test/         # End-to-end tests
├── assets/
│   ├── l10n/                 # ARB localization source files
│   └── images/               # App images and logos
├── config/                   # Environment JSON configs
├── local_packages/
│   └── pauza_ui_kit/         # Shared UI component library
├── android/                  # Android native project
├── ios/                      # iOS native project
├── Makefile                  # Build, test, lint, generate targets
└── pubspec.yaml
```

### Feature Modules

| Feature | Description |
|---------|-------------|
| `auth` | Passwordless email OTP login, session management |
| `modes` | Create, edit, schedule app-blocking modes |
| `home` | Active session control (start/pause/stop blocking) |
| `restriction_lifecycle` | Plugin client, background worker, session sync |
| `stats` | Usage charts and daily/weekly breakdowns |
| `streaks` | Focus streak tracking |
| `friends` | Friend requests and social connections |
| `leaderboard` | Weekly focus score rankings |
| `profile` / `settings` | User profile and preferences |
| `nfc_chip_config` / `qr_code_config` | Physical unlock token configuration |
| `subscription` | RevenueCat premium entitlement gating |
| `sync` | Offline-first sync with pauza-server |
| `onboarding` | First-run permission flow |
| `permissions` | Runtime permission management |

## Architecture

The app follows a strict layered architecture:

```
Widget → BLoC → Repository (abstract interface + Impl) → DataSource (SQLite / REST API)
```

- **State management:** `flutter_bloc` (BLoC pattern)
- **Routing:** Helm (declarative, guard-based)
- **Local storage:** SQLite via `sqflite`; immutable collections via `fast_immutable_collections`
- **Networking:** Custom `ApiClient` with auth, retry, and logging middleware
- **DI:** `PauzaDependencies` bootstraps all repos and BLoCs at startup via AppFuse
- **Plugin:** `pauza_screen_time` handles native OS-level app restriction
- **Analytics:** Firebase

Data flows one way: **SQLite → plugin** for mode definitions; **plugin → SQLite** for runtime events.

## Localization

Source strings live in `assets/l10n/app_en.arb`. After adding or changing strings:

```bash
flutter gen-l10n
# or
make l10n
```

Access strings in widgets via `context.l10n`.

Supported locales: `en`, `ru`, `uz`, `uz-Cyrl`.

## Makefile Reference

| Target | Description |
|--------|-------------|
| `make all` | Full pipeline: generate + format + analyze + test |
| `make generate` | Run all code generation (l10n, assets, build_runner) |
| `make format` | Format code (120-char line width) |
| `make analyze` | Format check + strict static analysis |
| `make test` | Run unit and widget tests with coverage |
| `make integration` | Run integration tests on a connected device |
| `make coverage` | Generate coverage report |
| `make clean` | Remove build artifacts, coverage, and generated files |
| `make build-android` | Build release APK |
| `make build-ios` | Build release iOS archive |
| `make generate-icons` | Regenerate launcher icons |
| `make generate-splash` | Regenerate native splash screen |
| `make fix` | Format + auto-fix lint issues |
| `make get` | Install dependencies (`flutter pub get`) |
| `make upgrade` | Upgrade dependencies |
| `make doctor` | Run `flutter doctor` |

## Troubleshooting

**`flutter pub get` fails with git dependency error**
Ensure you have SSH access (or HTTPS) to `github.com/pauzaa/pauza_screen_time`. The plugin is fetched directly from GitHub.

**Build fails after pulling new changes**
Run `make generate` to regenerate localization and asset files before building.

**iOS build fails with entitlements error**
The Family Controls entitlement requires a paid Apple Developer account. Contact the project maintainer for provisioning profile access.

**`flutter analyze` reports errors in generated files**
Generated files (`lib/src/core/localization/gen/`) are excluded from analysis. If errors appear there, re-run `make generate`.

**Firebase initialization error**
Ensure `firebase_options.dart` exists. If missing, run `flutterfire configure` with the correct project credentials.
