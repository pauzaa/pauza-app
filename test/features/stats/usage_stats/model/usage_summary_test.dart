import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/features/stats/usage_stats/model/usage_summary.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

void main() {
  test('buildSummary uses explicit per-day totals for trend points', () {
    final summary = UsageSummary.buildSummary(
      current: <UsageStats>[
        _usage(packageId: 'a', minutes: 50, launches: 4),
        _usage(packageId: 'b', minutes: 10, launches: 1),
      ].lock,
      previous: <UsageStats>[_usage(packageId: 'a', minutes: 30, launches: 2)].lock,
      window: DateTimeRange(start: DateTime(2026, 2), end: DateTime(2026, 2, 3, 23, 59, 59, 999)),
      dailyDurations: IMap<DateTime, Duration>(<DateTime, Duration>{
        DateTime(2026, 2): const Duration(minutes: 20),
        DateTime(2026, 2, 2): const Duration(minutes: 10),
        DateTime(2026, 2, 3): const Duration(minutes: 30),
      }),
    );

    expect(summary.trend.length, 3);
    expect(summary.trend[0].day, DateTime(2026, 2));
    expect(summary.trend[0].duration, const Duration(minutes: 20));
    expect(summary.trend[1].day, DateTime(2026, 2, 2));
    expect(summary.trend[1].duration, const Duration(minutes: 10));
    expect(summary.trend[2].day, DateTime(2026, 2, 3));
    expect(summary.trend[2].duration, const Duration(minutes: 30));
  });
}

UsageStats _usage({required String packageId, required int minutes, required int launches}) {
  return UsageStats(
    appInfo: AndroidAppInfo(packageId: AppIdentifier.android(packageId), name: packageId),
    totalDuration: Duration(minutes: minutes),
    totalLaunchCount: launches,
    lastTimeUsed: DateTime(2026, 2, 3),
  );
}
