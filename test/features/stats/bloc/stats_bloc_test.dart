import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/core/common/pauza_platform.dart';
import 'package:pauza/src/features/stats/bloc/stats_bloc.dart';
import 'package:pauza/src/features/stats/bloc/stats_event.dart';
import 'package:pauza/src/features/stats/data/stats_usage_repository.dart';
import 'package:pauza/src/features/stats/model/stats_date_window.dart';
import 'package:pauza/src/features/stats/model/usage_category_bucket.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

void main() {
  group('StatsBloc', () {
    test('initializes with ISO week on start', () async {
      final bloc = StatsBloc(
        usageRepository: _FakeStatsUsageRepository(),
        now: () => DateTime(2026, 2, 15, 9),
      );

      bloc.add(const StatsStarted());
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.window.start, DateTime(2026, 2, 9));
      expect(bloc.state.window.end, DateTime(2026, 2, 15, 23, 59, 59, 999));

      await bloc.close();
    });

    test('shifts custom range by inclusive span', () async {
      final bloc = StatsBloc(
        usageRepository: _FakeStatsUsageRepository(),
        now: () => DateTime(2026, 2, 15, 9),
      );

      bloc.add(
        StatsDateRangePicked(
          DateTimeRange(start: DateTime(2025), end: DateTime(2025, 1, 14)),
        ),
      );
      await Future<void>.delayed(Duration.zero);

      bloc.add(const StatsDateRangeShifted(1));
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.window.start, DateTime(2025, 1, 15));
      expect(bloc.state.window.end, DateTime(2025, 1, 28, 23, 59, 59, 999));

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
        now: () => DateTime(2026, 2, 15, 9),
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

    test('marks missing permission errors', () async {
      final bloc = StatsBloc(
        usageRepository: _ErrorStatsUsageRepository(
          const PauzaMissingPermissionError(message: 'missing'),
        ),
        now: () => DateTime(2026, 2, 15, 9),
      );

      bloc.add(const StatsStarted());
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(bloc.state.hasMissingPermission, isTrue);
      expect(bloc.state.summary, isNull);

      await bloc.close();
    });

    test('does not load android stats on iOS platform', () async {
      final repo = _FakeStatsUsageRepository();
      final bloc = StatsBloc(
        usageRepository: repo,
        platform: PauzaPlatform.ios,
        now: () => DateTime(2026, 2, 15, 9),
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
  Future<List<UsageStats>> getUsageStats({
    required DateTime start,
    required DateTime end,
  }) async {
    calls++;
    return calls.isOdd ? current : previous;
  }
}

class _ErrorStatsUsageRepository implements StatsUsageRepository {
  _ErrorStatsUsageRepository(this.error);

  final Object error;

  @override
  Future<List<UsageStats>> getUsageStats({
    required DateTime start,
    required DateTime end,
  }) {
    return Future<List<UsageStats>>.error(error);
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
    bucketStart: StatsDateWindow.atDayStart(day),
    bucketEnd: StatsDateWindow.atDayEnd(day),
    lastTimeUsed: day,
  );
}
