import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/core/common/pauza_platform.dart';
import 'package:pauza/src/features/stats/usage_stats/bloc/stats_bloc.dart';
import 'package:pauza/src/features/stats/usage_stats/bloc/stats_event.dart';
import 'package:pauza/src/features/stats/usage_stats/data/stats_usage_repository.dart';
import 'package:pauza/src/features/stats/usage_stats/model/app_engagement_insight.dart';
import 'package:pauza/src/features/stats/usage_stats/model/device_usage_insights.dart';
import 'package:pauza/src/features/stats/usage_stats/model/usage_category_bucket.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

void main() {
  group('StatsBloc', () {
    test('initializes with valid date range on start', () async {
      final bloc = StatsBloc(
        usageRepository: _FakeStatsUsageRepository(),
        platform: PauzaPlatform.android,
      );

      bloc.add(const StatsStarted());
      await Future<void>.delayed(Duration.zero);

      // Verify that a window is set (not testing specific dates since DateTime.now() is used)
      expect(bloc.state.window.start.isBefore(bloc.state.window.end), isTrue);

      await bloc.close();
    });

    test('builds summary data on android success', () async {
      final repo = _FakeStatsUsageRepository(
        current: <UsageStats>[
          _usage(
            packageId: 'social.app',
            category: 'Social',
            minutes: 120,
            day: DateTime(2026, 2, 10),
          ),
          _usage(
            packageId: 'work.app',
            category: 'Productivity',
            minutes: 60,
            day: DateTime(2026, 2, 11),
          ),
        ],
        previous: <UsageStats>[
          _usage(
            packageId: 'social.app',
            category: 'Social',
            minutes: 60,
            day: DateTime(2026, 2, 3),
          ),
        ],
      );

      final bloc = StatsBloc(
        usageRepository: repo,
        platform: PauzaPlatform.android,
      );

      bloc.add(const StatsStarted());
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(bloc.state.summary, isNotNull);
      expect(bloc.state.summary!.totalDuration, const Duration(minutes: 180));
      expect(
        bloc.state.summary!.buckets[UsageCategoryBucket.social],
        const Duration(minutes: 120),
      );

      await bloc.close();
    });

    test('marks error state on permission errors', () async {
      final bloc = StatsBloc(
        usageRepository: _ErrorStatsUsageRepository(
          const PauzaMissingPermissionError(message: 'missing'),
        ),
        platform: PauzaPlatform.android,
      );

      bloc.add(const StatsStarted());
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(bloc.state.hasError, isTrue);
      expect(bloc.state.summary, isNull);

      await bloc.close();
    });

    test('does not load android stats on iOS platform', () async {
      final repo = _FakeStatsUsageRepository();
      final bloc = StatsBloc(
        usageRepository: repo,
        platform: PauzaPlatform.ios,
      );

      bloc.add(const StatsStarted());
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(repo.calls, 0);

      await bloc.close();
    });
  });
}

class _FakeStatsUsageRepository implements StatsUsageRepository {
  _FakeStatsUsageRepository({
    this.current = const <UsageStats>[],
    this.previous = const <UsageStats>[],
  });

  final List<UsageStats> current;
  final List<UsageStats> previous;
  var calls = 0;

  @override
  Future<IList<UsageStats>> getUsageStats({
    required DateTime start,
    required DateTime end,
    bool includeIcons = false,
  }) async {
    calls++;
    return calls.isOdd ? current.lock : previous.lock;
  }

  @override
  Future<UsageStats?> getAppUsageStats({
    required String packageId,
    required DateTime start,
    required DateTime end,
    bool includeIcons = false,
  }) async {
    return null;
  }

  @override
  Future<IList<UsageEvent>> getUsageEvents({
    required DateTime start,
    required DateTime end,
    IList<UsageEventType>? eventTypes,
  }) async {
    return const IListConst<UsageEvent>(<UsageEvent>[]);
  }

  @override
  Future<IList<DeviceEventStats>> getEventStats({
    required DateTime start,
    required DateTime end,
    UsageStatsInterval interval = UsageStatsInterval.daily,
  }) async {
    return const IListConst<DeviceEventStats>(<DeviceEventStats>[]);
  }

  @override
  Future<bool> isAppInactive({required String packageId}) async {
    return false;
  }

  @override
  Future<AppStandbyBucket> getAppStandbyBucket() async {
    return AppStandbyBucket.active;
  }

  @override
  Future<DeviceUsageInsights> getDeviceUsageInsights({
    required DateTime start,
    required DateTime end,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<IList<AppEngagementInsight>> getTopAppEngagementInsights({
    required DateTime start,
    required DateTime end,
    int limit = 5,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<IMap<int, Duration>> getHourlyScreenTimeHeatmap({
    required DateTime start,
    required DateTime end,
  }) {
    throw UnimplementedError();
  }
}

class _ErrorStatsUsageRepository implements StatsUsageRepository {
  _ErrorStatsUsageRepository(this.error);

  final Object error;

  @override
  Future<IList<UsageStats>> getUsageStats({
    required DateTime start,
    required DateTime end,
    bool includeIcons = false,
  }) {
    return Future<IList<UsageStats>>.error(error);
  }

  @override
  Future<UsageStats?> getAppUsageStats({
    required String packageId,
    required DateTime start,
    required DateTime end,
    bool includeIcons = false,
  }) {
    return Future<UsageStats?>.error(error);
  }

  @override
  Future<IList<UsageEvent>> getUsageEvents({
    required DateTime start,
    required DateTime end,
    IList<UsageEventType>? eventTypes,
  }) {
    return Future<IList<UsageEvent>>.error(error);
  }

  @override
  Future<IList<DeviceEventStats>> getEventStats({
    required DateTime start,
    required DateTime end,
    UsageStatsInterval interval = UsageStatsInterval.daily,
  }) {
    return Future<IList<DeviceEventStats>>.error(error);
  }

  @override
  Future<bool> isAppInactive({required String packageId}) {
    return Future<bool>.error(error);
  }

  @override
  Future<AppStandbyBucket> getAppStandbyBucket() {
    return Future<AppStandbyBucket>.error(error);
  }

  @override
  Future<DeviceUsageInsights> getDeviceUsageInsights({
    required DateTime start,
    required DateTime end,
  }) {
    return Future<DeviceUsageInsights>.error(error);
  }

  @override
  Future<IList<AppEngagementInsight>> getTopAppEngagementInsights({
    required DateTime start,
    required DateTime end,
    int limit = 5,
  }) {
    return Future<IList<AppEngagementInsight>>.error(error);
  }

  @override
  Future<IMap<int, Duration>> getHourlyScreenTimeHeatmap({
    required DateTime start,
    required DateTime end,
  }) {
    return Future<IMap<int, Duration>>.error(error);
  }
}

UsageStats _usage({
  required String packageId,
  required String category,
  required int minutes,
  required DateTime day,
}) {
  return UsageStats(
    appInfo: AndroidAppInfo(
      packageId: AppIdentifier.android(packageId),
      name: packageId,
      category: category,
    ),
    totalDuration: Duration(minutes: minutes),
    totalLaunchCount: 1,
    bucketStart: day.dayStart,
    bucketEnd: day.dayEnd,
    lastTimeUsed: day,
  );
}
