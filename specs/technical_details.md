# Pauza — Technical Details

**Status:** Draft  
**Last updated:** 2026-02-06  
**Owner:** Pauza team

## 1) State management
- Use **BLoC** (`flutter_bloc`) for state management.
- Prefer `Bloc` for event-driven flows and `Cubit` for simpler state.
- Use `equatable` where it improves readability (commonly for bloc events/states).
- Use immutable collections (`fast_immutable_collections`) in state to avoid accidental mutation (e.g., `IList`, `ISet`, `IMap`).

## 2) Routing
- Use **Helm** for routing: <https://pub.dev/packages/helm>.
- Keep route declarations centralized under `lib/src/core/` (avoid ad-hoc navigation calls from features).

## 3) App bootstrap (boilerplate reduction)
- Use **Appfuse** at the app root to reduce boilerplate and adopt the utilities it provides:
  - Pub: <https://pub.dev/packages/appfuse>
  - GitHub: <https://github.com/ulughbeck/appfuse>

## 4) Dependency injection
- Use `InheritedWidget` for lightweight DI where appropriate.
- Prefer **Appfuse DI** when available/fit for the app architecture.
- Avoid global singletons; dependencies should be created at the composition root and injected downward.

## 5) Localization (i18n)
- Use **Appfuse localization** as the primary localization approach (per Appfuse docs).
- Keep all user-facing strings localized; no hard-coded copy in widgets.

## 6) App shell & theming
- Use `MaterialApp`.
- Always use themes (`ThemeData` / `ColorScheme` / `TextTheme`); do **not** hard-code colors, typography, or spacing in feature code.
- New reusable UI components belong in the local `ui_kit` package (not in `lib/src`).

## 7) Core feature plugin: `pauza_screen_time`
- Use `pauza_screen_time` for app usage monitoring, app restriction/blocking, and permission/authorization flows.
- Plugin source (git): <https://github.com/IsroilovA/pauza_screen_time>.

**Platform constraints to account for:**
- **Android**
  - Can enumerate installed apps and return usage stats as data.
  - Requires **Usage Access** and **Accessibility** permissions to be enabled in Settings.
- **iOS**
  - Cannot enumerate installed apps; uses **picker tokens** for selection.
  - Usage stats are **UI-only** via `DeviceActivityReport` (`IOSUsageReportView`), and require an extension.
  - Requires Screen Time / **FamilyControls** authorization.
  - Shield configuration should use an **App Group** (otherwise setup errors like `APP_GROUP_ERROR` are likely).

## 8) Collections utilities
- Add `fast_immutable_collections`: <https://pub.dev/packages/fast_immutable_collections>
- Add `collection`: <https://pub.dev/packages/collection>

## 9) Database & persistence
- Use SQLite for on-device persistence.
- Prefer `sqflite` (or an equivalent SQLite Flutter plugin) for database access.
- Keep persistence behind a repository layer (abstract interface + concrete implementation).

## 10) Packages to include (summary)
Planned dependencies (versions TBD per Flutter/Dart constraints):
- `flutter_bloc`
- `helm`
- `appfuse`
- `pauza_screen_time`
- `fast_immutable_collections`
- `collection`
- `equatable`
- `sqflite`
