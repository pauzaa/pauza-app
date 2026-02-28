# UsageStats Module Guide

This guide explains how to use the `UsageStats` module in `pauza_screen_time`, what each API does, and how data flows under the hood.

## What the module provides

The module is split by platform:

- Android: data APIs through `UsageStatsManager`.
- iOS: embedded native report UI through `UsageReportView` / `IOSUsageReportView`.

Important:

- `UsageStatsManager` methods are Android-only.
- On iOS, these methods throw `PauzaUnsupportedError`.
- iOS usage is exposed as a native report view, not Dart data objects.

## Imports

```dart
import 'package:pauza_screen_time/pauza_screen_time.dart';
```

## Prerequisites

### Android

You must grant Usage Access permission before querying stats:

```dart
final permissions = PermissionManager();
await permissions.requestAndroidPermission(AndroidPermission.usageStats);
```

Without this permission, UsageStats calls fail with taxonomy code `MISSING_PERMISSION` (mapped to `PauzaMissingPermissionError`).

### iOS

To show usage reports, you must configure a Device Activity Report extension in the host app. The Flutter widget only embeds that native report.

## Android APIs (`UsageStatsManager`)

Create one manager instance:

```dart
final usage = UsageStatsManager();
```

### 1) `getUsageStats(...)`

Returns usage stats for all apps in a time range.

```dart
final now = DateTime.now();
final stats = await usage.getUsageStats(
  startDate: now.subtract(const Duration(days: 7)),
  endDate: now,
  includeIcons: true,
);
```

Parameters:

- `startDate`, `endDate`: query window.
- `includeIcons`: include app icon bytes (`true` by default). Disable for better performance if icons are not needed.
- `cancelToken`, `timeout`: optional call control.

Returns:

- `List<UsageStats>` filtered to apps with foreground time > 0.

### 2) `getAppUsageStats(...)`

Returns usage stats for one app package in a time range.

```dart
final appStat = await usage.getAppUsageStats(
  packageId: 'com.whatsapp',
  startDate: DateTime.now().subtract(const Duration(days: 7)),
  endDate: DateTime.now(),
);
```

Returns:

- `UsageStats?`
- `null` when the app has no foreground usage in the range.

### 3) `getUsageEvents(...)`

Returns raw timestamped usage events.

```dart
final events = await usage.getUsageEvents(
  startDate: DateTime.now().subtract(const Duration(days: 2)),
  endDate: DateTime.now(),
  eventTypes: const [
    UsageEventType.activityResumed,
    UsageEventType.activityPaused,
  ],
);
```

Notes:

- If `eventTypes` is omitted, all event types are returned.
- Android typically keeps raw events only for a short retention window (usually a few days).

### 4) `getEventStats(...)`

Returns aggregated device-level event statistics.

```dart
final deviceStats = await usage.getEventStats(
  startDate: DateTime.now().subtract(const Duration(days: 7)),
  endDate: DateTime.now(),
  intervalType: UsageStatsInterval.daily,
);
```

Typical event types include screen interactive/non-interactive and keyguard shown/hidden.

Compatibility:

- Requires Android 9+ (API 28+).
- On lower API levels, the call fails with a typed error (taxonomy `UNSUPPORTED`).

### 5) `isAppInactive(...)`

Checks whether the given app is currently considered inactive by Android.

```dart
final inactive = await usage.isAppInactive(packageId: 'com.whatsapp');
```

### 6) `getAppStandbyBucket()`

Returns the standby bucket for the calling app.

```dart
final bucket = await usage.getAppStandbyBucket();
```

Possible values: `active`, `workingSet`, `frequent`, `rare`, `restricted`, `unknown`.

Compatibility:

- Requires Android 9+ (API 28+).

## Data models you receive

### `UsageStats`

Includes:

- `appInfo`: package, name, optional icon, category, system-app flag.
- `totalDuration`: foreground duration in query period.
- `totalLaunchCount`: launch count inferred from `ACTIVITY_RESUMED` events.
- `bucketStart` / `bucketEnd`: Android usage bucket boundaries.
- `lastTimeUsed`: last foreground usage timestamp.
- `lastTimeVisible`: last visible time (Android Q+).

### `UsageEvent`

Each event includes:

- `timestamp`
- `packageName`
- `className` (nullable)
- `eventType` (`UsageEventType` enum)

### `DeviceEventStats`

Aggregated values per event type:

- `count`
- `totalTime`
- `firstTimestamp`
- `lastTimestamp`
- `lastEventTime`

## iOS usage reports (`UsageReportView`)

Use the widget to embed Apple Screen Time reports in your Flutter UI:

```dart
IOSUsageReportView(
  reportContext: 'daily',
  segment: IOSUsageReportSegment.daily,
  startDate: DateTime.now().subtract(const Duration(days: 7)),
  endDate: DateTime.now(),
  fallback: const SizedBox.shrink(),
)
```

Parameters:

- `reportContext`: passed to `DeviceActivityReport.Context(...)` on iOS.
- `segment`: `daily` or `hourly`.
- `startDate`, `endDate`: report interval.
- `fallback`: widget rendered on non-iOS/web.

Important:

- Your iOS report extension must support the same `reportContext` IDs.
- `UsageReportView` is iOS-only; on other platforms it shows `fallback` (or empty box).

## Error handling

UsageStats APIs throw typed `PauzaError` exceptions.

Common taxonomy codes:

- `MISSING_PERMISSION`: Usage Access not granted on Android.
- `UNSUPPORTED`: unsupported platform or API level.
- `INVALID_ARGUMENT`: invalid/missing method parameters.
- `INTERNAL_FAILURE`: native/channel/decoding failure.

Recommended handling pattern:

```dart
try {
  final usage = UsageStatsManager();
  final now = DateTime.now();

  final stats = await usage.getUsageStats(
    startDate: now.subtract(const Duration(days: 1)),
    endDate: now,
  );

  // Use stats.
} on PauzaMissingPermissionError {
  // Ask user to grant Usage Access in system settings.
} on PauzaUnsupportedError {
  // Hide/disable feature on this platform/API level.
} on PauzaError catch (e) {
  // Log and handle generic plugin error.
  debugPrint('UsageStats failed: ${e.rawCode}, details: ${e.details}');
}
```

## How it works under the hood

This section is intentionally high-level so you can reason about behavior.

### Android pipeline

1. Dart API (`UsageStatsManager`) validates platform and calls `UsageStatsMethodChannel`.
2. Dates are converted to epoch milliseconds and sent via method channel.
3. Native `UsageStatsMethodHandler` routes each action to focused repositories:
   - `UsageStatsRepository`
   - `UsageEventsRepository`
   - `DeviceEventStatsRepository`
   - `AppStatusRepository`
4. Repositories call Android `UsageStatsManager` system APIs.
5. Permission checks happen natively; missing access is mapped to `MISSING_PERMISSION`.
6. Results are serialized back to maps/lists and decoded into Dart models.
7. Decode mismatches are treated as `INTERNAL_FAILURE` (strict schema behavior).

Performance detail:

- `getUsageStats` computes launch counts with a single event scan to avoid per-app event scans.
- App icons are optional because extracting icon bytes can be expensive.

### iOS pipeline

1. Flutter builds `UsageReportView` (`UiKitView`) with creation params.
2. Native factory creates `UsageReportPlatformView`.
3. A SwiftUI `DeviceActivityReport` view is hosted inside the platform view.
4. `reportContext`, `segment`, and interval are mapped into a `DeviceActivityFilter`.
5. Apple’s extension renders the report UI.

Key design consequence:

- iOS does not expose raw usage stats as Dart-readable data through this module.
- The plugin intentionally exposes usage as embeddable native UI.

## Practical recommendations

- Always request/check Usage Access before Android queries.
- Use shorter windows for `getUsageEvents` because event retention is limited.
- Disable `includeIcons` in list-heavy screens if you only need numeric stats.
- Guard API 28+ methods (`getEventStats`, `getAppStandbyBucket`) in UX flows.
- Keep iOS report contexts consistent with your extension implementation.

## Quick API summary

- Android data:
  - `getUsageStats`
  - `getAppUsageStats`
  - `getUsageEvents`
  - `getEventStats` (API 28+)
  - `isAppInactive`
  - `getAppStandbyBucket` (API 28+)
- iOS UI:
  - `UsageReportView` / `IOSUsageReportView`
