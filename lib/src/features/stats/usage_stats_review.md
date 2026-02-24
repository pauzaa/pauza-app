# Usage Stats Feature — Code Review

Covers [StatsUsageRepositoryImpl](file:///Users/alisher/University/bisp/pauza/lib/src/features/stats/usage_stats/data/stats_usage_repository.dart#43-404), [DeviceUsageInsights](file:///Users/alisher/University/bisp/pauza/lib/src/features/stats/usage_stats/model/device_usage_insights.dart#5-77), [AppEngagementInsight](file:///Users/alisher/University/bisp/pauza/lib/src/features/stats/usage_stats/model/app_engagement_insight.dart#4-56), [UsageSummary](file:///Users/alisher/University/bisp/pauza/lib/src/features/stats/usage_stats/model/usage_summary.dart#26-118), `UsageCategoryBucket`, and the repository test suite.

---

## 🐛 Bugs

### 1. `installedAppsManager` is accepted but silently discarded
[stats_usage_repository.dart](file:///Users/alisher/University/bisp/pauza/lib/src/features/stats/usage_stats/data/stats_usage_repository.dart#L43-L49)

```dart
StatsUsageRepositoryImpl({
  required UsageStatsManager usageStatsManager,
  required InstalledAppsManager installedAppsManager,  // ← accepted
}) : _usageStatsManager = usageStatsManager;           // ← installedAppsManager never stored
```

The parameter is declared `required`, callers must provide it, yet it is **never assigned to a field and never used**. This is confusing and wastes the caller's effort (plus hides a future intention that was never finished). Either remove the parameter, or actually store and use it (e.g. to enrich app metadata in [getTopAppEngagementInsights](file:///Users/alisher/University/bisp/pauza/lib/src/features/stats/usage_stats/data/stats_usage_repository.dart#183-220)).

---

### 2. [getDeviceUsageInsights](file:///Users/alisher/University/bisp/pauza/lib/src/features/stats/usage_stats/data/stats_usage_repository.dart#121-181) fetches usage events twice when event-stats succeed
[stats_usage_repository.dart L122-L125](file:///Users/alisher/University/bisp/pauza/lib/src/features/stats/usage_stats/data/stats_usage_repository.dart#L122-L125)

```dart
final (eventStats, fallbackEvents, source) = await _safeGetEventStatsOrFallback(...);
final relevantEvents =
    fallbackEvents ?? await getUsageEvents(..., eventTypes: _deviceInsightsEventTypes);
```

When `source == eventStats`, `fallbackEvents` is `null`, so [getUsageEvents](file:///Users/alisher/University/bisp/pauza/test/features/stats/usage_stats/data/stats_usage_repository_test.dart#177-189) is called unconditionally **to compute `firstUnlockAt` / `lastUnlockAt`**. Those two timestamps are then derived from `unlockEvents` regardless of source path.

This means **every call to [getDeviceUsageInsights](file:///Users/alisher/University/bisp/pauza/lib/src/features/stats/usage_stats/data/stats_usage_repository.dart#121-181) on a device that supports event-stats issues two network/IPC round-trips**: one for event-stats, one for usage-events. The usage-events call should only happen in the fallback branch, and `firstUnlockAt`/`lastUnlockAt` should be populated from `DeviceEventStats.firstTimestamp`/`lastTimestamp` (already present on the model) in the fast path.

---

### 3. [getTopAppEngagementInsights](file:///Users/alisher/University/bisp/pauza/lib/src/features/stats/usage_stats/data/stats_usage_repository.dart#183-220) — redundant `where` filter after [getUsageStats](file:///Users/alisher/University/bisp/pauza/test/features/stats/usage_stats/data/stats_usage_repository_test.dart#153-163)
[stats_usage_repository.dart L195-L196](file:///Users/alisher/University/bisp/pauza/lib/src/features/stats/usage_stats/data/stats_usage_repository.dart#L195-L196)

```dart
.where((usage) => usage.totalDuration > Duration.zero || usage.totalLaunchCount > 0)
```

[getUsageStats](file:///Users/alisher/University/bisp/pauza/test/features/stats/usage_stats/data/stats_usage_repository_test.dart#153-163) already filters out items whose `totalDuration <= Duration.zero` (line 66). An app with `totalDuration == zero` could only pass the second predicate (`totalLaunchCount > 0`), which is an untracked edge case in the data. The filter is therefore partially redundant and misleading — it implies the call could return zero-duration items, which it cannot (per the calling method). At minimum, document why the `|| totalLaunchCount > 0` leg is needed; otherwise remove the entire `where`.

---

### 4. [_sumDurationBetweenEventPairs](file:///Users/alisher/University/bisp/pauza/lib/src/features/stats/usage_stats/data/stats_usage_repository.dart#339-370) treats a repeated `startType` event as a no-op when it should reset
[stats_usage_repository.dart L350-L354](file:///Users/alisher/University/bisp/pauza/lib/src/features/stats/usage_stats/data/stats_usage_repository.dart#L350-L354)

```dart
if (event.eventType == startType) {
  activeStart = event.timestamp.isAfter(start) ? event.timestamp : start;
  continue;  // ← silently overwrites without closing previous interval
}
```

If two consecutive `screenInteractive` events appear without an intervening `screenNonInteractive` (which happens when the device re-wakes without sleeping, e.g. incoming call), the first active session is silently abandoned and its time is lost. The correct behaviour is to close the old interval at `event.timestamp` before opening the new one (or at least clamp).

---

### 5. [_accumulateDurationsByHour](file:///Users/alisher/University/bisp/pauza/lib/src/features/stats/usage_stats/data/stats_usage_repository.dart#304-329) double-clips intervals
[stats_usage_repository.dart L304-L328](file:///Users/alisher/University/bisp/pauza/lib/src/features/stats/usage_stats/data/stats_usage_repository.dart#L304-L328)

Each interval passed in has **already been clipped** by [_buildIntervalsFromUsageEvents](file:///Users/alisher/University/bisp/pauza/lib/src/features/stats/usage_stats/data/stats_usage_repository.dart#263-303) (line 288). Inside [_accumulateDurationsByHour](file:///Users/alisher/University/bisp/pauza/lib/src/features/stats/usage_stats/data/stats_usage_repository.dart#304-329), the first thing done is clip again (line 312). This is harmless but wastes cycles on every interval. The inner [_clipInterval](file:///Users/alisher/University/bisp/pauza/lib/src/features/stats/usage_stats/data/stats_usage_repository.dart#371-384) call can be removed.

---

## ⚠️ Design / Logic Concerns

### 6. Engagement score formula has unexplained magic weights
[stats_usage_repository.dart L201](file:///Users/alisher/University/bisp/pauza/lib/src/features/stats/usage_stats/data/stats_usage_repository.dart#L201)

```dart
final engagementScore = (launches * 0.6) + (usage.totalDuration.inMinutes * 0.4);
```

The `0.6 / 0.4` split is arbitrary and undocumented. More importantly, the two terms are on **completely different scales** — `launches` is typically a small integer (1–50) while `totalDuration.inMinutes` can be hundreds. A 30-minute session alone contributes 12 points vs. 0.6 per launch, so `launches` is nearly irrelevant for any app with non-trivial duration. This almost certainly does not produce the intended ranking. Consider normalizing both dimensions or switching to a formula with documented semantics (e.g. `duration / avgDuration * weight + launches / avgLaunches * weight`).

---

### 7. `getHourlyScreenTimeheatmap` fallback distributes all duration into a single hour
[stats_usage_repository.dart L240-L246](file:///Users/alisher/University/bisp/pauza/lib/src/features/stats/usage_stats/data/stats_usage_repository.dart#L240-L246)

```dart
final basis = usage.lastTimeUsed ?? start;
buckets[basis.hour] = (buckets[basis.hour] ?? Duration.zero) + usage.totalDuration;
```

The fallback path (when no activity events are available) dumps the **entire daily/weekly duration** of an app into the **single hour** of `lastTimeUsed`. A user who spent 3 hours on YouTube ending at 22:15 gets all 3 h attributed to hour 22. This makes the fallback heatmap look very "spiky" and misleading. A better fallback is to spread the duration evenly across waking hours (e.g. 08–23), or to clearly document the limitation in a comment so future maintainers don't assume the heatmap is accurate.

---

### 8. `safePickupCount` guard hides real data
[stats_usage_repository.dart L165](file:///Users/alisher/University/bisp/pauza/lib/src/features/stats/usage_stats/data/stats_usage_repository.dart#L165)

```dart
final safePickupCount = pickupCount <= 0 ? 1 : pickupCount;
```

Substituting `1` for `0` makes `screenOnSessionAverage` equal to `screenOnDuration` when there are no pickups. This silently inflates the average rather than returning `Duration.zero` (which is more honest). The UI should handle a `null` or `zero` average gracefully instead of having the repository fabricate a number. At minimum, add a comment explaining the sentinel.

---

### 9. [_findEventStat](file:///Users/alisher/University/bisp/pauza/lib/src/features/stats/usage_stats/data/stats_usage_repository.dart#330-338) is O(n) and called up to 4 times sequentially
[stats_usage_repository.dart L330-L337](file:///Users/alisher/University/bisp/pauza/lib/src/features/stats/usage_stats/data/stats_usage_repository.dart#L330-L337)

[_findEventStat](file:///Users/alisher/University/bisp/pauza/lib/src/features/stats/usage_stats/data/stats_usage_repository.dart#330-338) does a linear scan over the event-stats list, and it is called four times in [getDeviceUsageInsights](file:///Users/alisher/University/bisp/pauza/lib/src/features/stats/usage_stats/data/stats_usage_repository.dart#121-181). For a small list this is fine, but a simple `IMap<UsageEventType, DeviceEventStats>` indexed once would be cleaner and signal intent. This is a readability/refactoring suggestion rather than a bug.

---

### 10. `UsageSummary.buildSummary` — trend attribution relies on `lastTimeUsed` across multi-day windows
[usage_summary.dart L62-L67](file:///Users/alisher/University/bisp/pauza/lib/src/features/stats/usage_stats/model/usage_summary.dart#L62-L67)

```dart
final basis = item.lastTimeUsed ?? item.bucketStart ?? window.start;
final key = basis.dayStart;
```

For a 7-day window, [getUsageStats](file:///Users/alisher/University/bisp/pauza/test/features/stats/usage_stats/data/stats_usage_repository_test.dart#153-163) returns aggregated usage across the entire period, yet the entire duration is attributed to the day of `lastTimeUsed`. An app used for 2 h on Monday and 1 h on Friday shows up as 3 h on Friday. This is an inherent limitation of the [UsageStats](file:///Users/alisher/University/bisp/pauza/test/features/stats/usage_stats/data/stats_usage_repository_test.dart#153-163) API (which only returns a total for the window), so you either need to call per-day stats (one call per day in the window) or document this limitation prominently on [UsageSummary](file:///Users/alisher/University/bisp/pauza/lib/src/features/stats/usage_stats/model/usage_summary.dart#26-118).

---

## 🔧 Minor Refactoring Suggestions

### 11. [getTopAppEngagementInsights](file:///Users/alisher/University/bisp/pauza/lib/src/features/stats/usage_stats/data/stats_usage_repository.dart#183-220) — `take` is redundant when `insights.length <= limit`
[stats_usage_repository.dart L214-L218](file:///Users/alisher/University/bisp/pauza/lib/src/features/stats/usage_stats/data/stats_usage_repository.dart#L214-L218)

```dart
if (insights.length <= limit) {
  return insights;
}
return insights.take(limit).toIList();
```

Simplify to `return insights.take(limit).toIList();` — `take` on an `IList` shorter than `limit` is a no-op.

---

### 12. `UsageCategoryBucket.getColorForFonutBucket` — typo in method name

```dart
Color getColorForFonutBucket(ColorScheme colorScheme)
//                  ^^^^^ should be "FontBucket" or "ForBucket" — "Fonut" is a typo
```

---

### 13. Test: [_repository](file:///Users/alisher/University/bisp/pauza/test/features/stats/usage_stats/data/stats_usage_repository_test.dart#137-140) passes `InstalledAppsManager()` by constructing a real instance
[stats_usage_repository_test.dart L138](file:///Users/alisher/University/bisp/pauza/test/features/stats/usage_stats/data/stats_usage_repository_test.dart#L138)

```dart
StatsUsageRepositoryImpl(usageStatsManager: platform, installedAppsManager: InstalledAppsManager())
```

This works only because the parameter is discarded (Bug #1). As soon as `installedAppsManager` is actually used, this test will either need a fake or will hit platform channel errors. Pre-emptively swap it for a fake/mock.

---

### 14. [DeviceUsageInsights](file:///Users/alisher/University/bisp/pauza/lib/src/features/stats/usage_stats/model/device_usage_insights.dart#5-77) — no `copyWith`

The model is `@immutable` with 10 required fields. A `copyWith` method (standard in this project's other models) would help both tests and UI code that needs to update a single field.

---

## Summary Table

| # | File | Severity | Type |
|---|------|----------|------|
| 1 | [stats_usage_repository.dart](file:///Users/alisher/University/bisp/pauza/lib/src/features/stats/usage_stats/data/stats_usage_repository.dart) | 🔴 High | Bug — dead required parameter |
| 2 | [stats_usage_repository.dart](file:///Users/alisher/University/bisp/pauza/lib/src/features/stats/usage_stats/data/stats_usage_repository.dart) | 🔴 High | Bug — double IPC call on fast path |
| 3 | [stats_usage_repository.dart](file:///Users/alisher/University/bisp/pauza/lib/src/features/stats/usage_stats/data/stats_usage_repository.dart) | 🟡 Med | Bug — misleading/redundant filter |
| 4 | [stats_usage_repository.dart](file:///Users/alisher/University/bisp/pauza/lib/src/features/stats/usage_stats/data/stats_usage_repository.dart) | 🔴 High | Bug — consecutive start events lose time |
| 5 | [stats_usage_repository.dart](file:///Users/alisher/University/bisp/pauza/lib/src/features/stats/usage_stats/data/stats_usage_repository.dart) | 🟢 Low | Perf — redundant clip in accumulator |
| 6 | [stats_usage_repository.dart](file:///Users/alisher/University/bisp/pauza/lib/src/features/stats/usage_stats/data/stats_usage_repository.dart) | 🟡 Med | Logic — broken engagement score scaling |
| 7 | [stats_usage_repository.dart](file:///Users/alisher/University/bisp/pauza/lib/src/features/stats/usage_stats/data/stats_usage_repository.dart) | 🟡 Med | Logic — misleading heatmap fallback |
| 8 | [stats_usage_repository.dart](file:///Users/alisher/University/bisp/pauza/lib/src/features/stats/usage_stats/data/stats_usage_repository.dart) | 🟡 Med | Logic — fabricated average hides zero |
| 9 | [stats_usage_repository.dart](file:///Users/alisher/University/bisp/pauza/lib/src/features/stats/usage_stats/data/stats_usage_repository.dart) | 🟢 Low | Refactor — O(n)×4 linear scans |
| 10 | [usage_summary.dart](file:///Users/alisher/University/bisp/pauza/lib/src/features/stats/usage_stats/model/usage_summary.dart) | 🟡 Med | Logic — trend attribution per-window |
| 11 | [stats_usage_repository.dart](file:///Users/alisher/University/bisp/pauza/lib/src/features/stats/usage_stats/data/stats_usage_repository.dart) | 🟢 Low | Refactor — unnecessary branch |
| 12 | [usage_category_bucket.dart](file:///Users/alisher/University/bisp/pauza/lib/src/features/stats/usage_stats/model/usage_category_bucket.dart) | 🟢 Low | Typo in method name |
| 13 | [stats_usage_repository_test.dart](file:///Users/alisher/University/bisp/pauza/test/features/stats/usage_stats/data/stats_usage_repository_test.dart) | 🟡 Med | Test — fragile real-class dependency |
| 14 | [device_usage_insights.dart](file:///Users/alisher/University/bisp/pauza/lib/src/features/stats/usage_stats/model/device_usage_insights.dart) | 🟢 Low | Missing `copyWith` |
