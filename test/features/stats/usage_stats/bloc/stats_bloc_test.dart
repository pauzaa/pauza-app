import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/core/common/pauza_platform.dart';
import 'package:pauza/src/features/stats/usage_stats/bloc/stats_bloc.dart';
import 'package:pauza/src/features/stats/usage_stats/bloc/stats_event.dart';
import 'package:pauza/src/features/stats/usage_stats/model/app_engagement_insight.dart';
import 'package:pauza/src/features/stats/usage_stats/model/device_usage_insights.dart';
import 'package:pauza/src/features/stats/usage_stats/model/stats_section_status.dart';
import 'package:pauza/src/features/stats/usage_stats/model/usage_category_bucket.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

import '../helpers/fake_stats_usage_repository.dart';

void main() {
  group('StatsBloc', () {
    test('builds summary and insights on android success', () async {
      final repo = FakeStatsUsageRepository(
        current: <UsageStats>[
          _usage(packageId: 'social.app', category: 'Social', minutes: 120, day: DateTime(2026, 2, 10)),
          _usage(packageId: 'work.app', category: 'Productivity', minutes: 60, day: DateTime(2026, 2, 11)),
        ],
        previous: <UsageStats>[
          _usage(packageId: 'social.app', category: 'Social', minutes: 60, day: DateTime(2026, 2, 3)),
        ],
        dailyDurations: IMap<DateTime, Duration>(<DateTime, Duration>{
          DateTime(2026, 2, 10): const Duration(minutes: 120),
          DateTime(2026, 2, 11): const Duration(minutes: 60),
        }),
      );

      final bloc = StatsBloc(usageRepository: repo, platform: PauzaPlatform.android);

      bloc.add(const StatsStarted());
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(bloc.state.summary, isNotNull);
      expect(bloc.state.summary!.totalDuration, const Duration(minutes: 180));
      expect(bloc.state.summary!.buckets[UsageCategoryBucket.social], const Duration(minutes: 120));
      expect(bloc.state.deviceInsightsStatus, StatsSectionStatus.success);
      expect(bloc.state.topEngagementStatus, StatsSectionStatus.success);
      expect(bloc.state.heatmapStatus, StatsSectionStatus.success);
      expect(repo.dailyDurationsCalls, 1);

      await bloc.close();
    });

    test('date range pick refreshes insights with selected window', () async {
      final repo = FakeStatsUsageRepository();
      final bloc = StatsBloc(usageRepository: repo, platform: PauzaPlatform.android);

      final selectedRange = DateTimeRange(start: DateTime(2026, 2, 1, 8), end: DateTime(2026, 2, 3, 14));

      bloc.add(StatsDateRangePicked(selectedRange));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(repo.lastDeviceInsightsStart, DateTime(2026, 2));
      expect(repo.lastDeviceInsightsEnd, DateTime(2026, 2, 3, 23, 59, 59, 999));
      expect(repo.lastTopEngagementStart, DateTime(2026, 2));
      expect(repo.lastTopEngagementEnd, DateTime(2026, 2, 3, 23, 59, 59, 999));
      expect(repo.lastHeatmapStart, DateTime(2026, 2));
      expect(repo.lastHeatmapEnd, DateTime(2026, 2, 3, 23, 59, 59, 999));
      expect(repo.lastDailyDurationsStart, DateTime(2026, 2));
      expect(repo.lastDailyDurationsEnd, DateTime(2026, 2, 3, 23, 59, 59, 999));

      await bloc.close();
    });

    test('permission error from insight sets global error fallback state', () async {
      final repo = FakeStatsUsageRepository(deviceInsightsError: const PauzaMissingPermissionError(message: 'missing'));
      final bloc = StatsBloc(usageRepository: repo, platform: PauzaPlatform.android);

      bloc.add(const StatsStarted());
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(bloc.state.hasError, isTrue);
      expect(bloc.state.summary, isNull);

      await bloc.close();
    });

    test('partial insight failures keep summary and mark only failed sections', () async {
      final repo = FakeStatsUsageRepository(topEngagementError: Exception('boom'));
      final bloc = StatsBloc(usageRepository: repo, platform: PauzaPlatform.android);

      bloc.add(const StatsStarted());
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(bloc.state.summary, isNotNull);
      expect(bloc.state.hasError, isFalse);
      expect(bloc.state.deviceInsightsStatus, StatsSectionStatus.success);
      expect(bloc.state.topEngagementStatus, StatsSectionStatus.failure);
      expect(bloc.state.heatmapStatus, StatsSectionStatus.success);

      await bloc.close();
    });

    test('empty insights map to empty section statuses', () async {
      final repo = FakeStatsUsageRepository(
        deviceInsights: const DeviceUsageInsights(
          unlockCount: 0,
          lockCount: 0,
          pickupCount: 0,
          screenOnDuration: Duration.zero,
          unlockedDuration: Duration.zero,
          screenOnSessionAverage: null,
          unlocksPerDayAverage: 0,
          firstUnlockAt: null,
          lastUnlockAt: null,
          source: DeviceUsageInsightsSource.eventStats,
        ),
        topEngagement: const IListConst<AppEngagementInsight>(<AppEngagementInsight>[]),
        heatmap: IMap<int, Duration>.fromEntries(List.generate(24, (index) => MapEntry(index, Duration.zero))),
      );
      final bloc = StatsBloc(usageRepository: repo, platform: PauzaPlatform.android);

      bloc.add(const StatsStarted());
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(bloc.state.deviceInsightsStatus, StatsSectionStatus.empty);
      expect(bloc.state.topEngagementStatus, StatsSectionStatus.empty);
      expect(bloc.state.heatmapStatus, StatsSectionStatus.empty);

      await bloc.close();
    });

    test('clears stale global error after successful retry on same bloc', () async {
      final repo = _FlakyStatsUsageRepository();
      final bloc = StatsBloc(usageRepository: repo, platform: PauzaPlatform.android);

      bloc.add(const StatsStarted());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(bloc.state.hasError, isTrue);

      repo.shouldFail = false;
      bloc.add(const StatsRefreshRequested());
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(bloc.state.hasError, isFalse);
      expect(bloc.state.summary, isNotNull);

      await bloc.close();
    });

    test('does not load android stats on iOS platform', () async {
      final repo = FakeStatsUsageRepository();
      final bloc = StatsBloc(usageRepository: repo, platform: PauzaPlatform.ios);

      bloc.add(const StatsStarted());
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(repo.calls, 0);
      expect(repo.deviceInsightsCalls, 0);
      expect(repo.topEngagementCalls, 0);
      expect(repo.heatmapCalls, 0);

      await bloc.close();
    });
  });
}

UsageStats _usage({required String packageId, required String category, required int minutes, required DateTime day}) {
  return UsageStats(
    appInfo: AndroidAppInfo(packageId: AppIdentifier.android(packageId), name: packageId, category: category),
    totalDuration: Duration(minutes: minutes),
    totalLaunchCount: 1,
    bucketStart: day.dayStart,
    bucketEnd: day.dayEnd,
    lastTimeUsed: day,
  );
}

final class _FlakyStatsUsageRepository extends FakeStatsUsageRepository {
  _FlakyStatsUsageRepository();

  bool shouldFail = true;

  @override
  Future<DeviceUsageInsights> getDeviceUsageInsights({required DateTime start, required DateTime end}) async {
    if (shouldFail) {
      throw const PauzaMissingPermissionError(message: 'missing');
    }
    return super.getDeviceUsageInsights(start: start, end: end);
  }
}
