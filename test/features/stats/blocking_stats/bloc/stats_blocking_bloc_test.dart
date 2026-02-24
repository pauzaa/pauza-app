import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:pauza/src/features/stats/blocking_stats/bloc/stats_blocking_bloc.dart';
import 'package:pauza/src/features/stats/blocking_stats/model/blocking_daily_point.dart';
import 'package:pauza/src/features/stats/blocking_stats/model/blocking_stats_snapshot.dart';
import 'package:pauza/src/features/streaks/common/model/streak_types.dart';

import '../helpers/fake_stats_blocking_repository.dart';

void main() {
  group('StatsBlockingBloc', () {
    test('loads snapshot on start', () async {
      final repo = FakeStatsBlockingRepository(responses: <Object>[_snapshot()]);
      final bloc = StatsBlockingBloc(repository: repo);

      bloc.add(const StatsBlockingStarted());
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(repo.calls, 1);
      expect(bloc.state.snapshot, isNotNull);
      expect(bloc.state.snapshot!.currentStreakDays, 3);

      await bloc.close();
    });

    test('date range pick normalizes window and reloads', () async {
      final repo = FakeStatsBlockingRepository(responses: <Object>[_snapshot(), _snapshot()]);
      final bloc = StatsBlockingBloc(repository: repo);

      bloc.add(
        StatsBlockingDateRangePicked(DateTimeRange(start: DateTime(2026, 2, 1, 8), end: DateTime(2026, 2, 3, 9))),
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(repo.calls, 1);
      expect(bloc.state.window.start, DateTime(2026, 2));
      expect(bloc.state.window.end, DateTime(2026, 2, 3, 23, 59, 59, 999));

      await bloc.close();
    });

    test('emits error state when repository fails', () async {
      final repo = FakeStatsBlockingRepository(responses: <Object>[StateError('boom')]);
      final bloc = StatsBlockingBloc(repository: repo);

      bloc.add(const StatsBlockingStarted());
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(bloc.state.hasError, isTrue);
      expect(bloc.state.snapshot, isNull);

      await bloc.close();
    });
  });
}

BlockingStatsSnapshot _snapshot() {
  return const BlockingStatsSnapshot(
    currentStreakDays: 3,
    longestStreakDays: 9,
    averageRestrictionSessionDuration: Duration(minutes: 15),
    longestRestrictionSessionDuration: Duration(minutes: 40),
    averagePausesPerSession: 1.5,
    averagePauseDuration: Duration(minutes: 3),
    completedSessionsCount: 4,
    totalEffectiveBlockedDuration: Duration(minutes: 50),
    totalPausedDuration: Duration(minutes: 10),
    dailyTrend: IListConst<BlockingDailyPoint>(<BlockingDailyPoint>[
      BlockingDailyPoint(localDay: LocalDayKey('2026-02-01'), effectiveDuration: Duration(minutes: 20)),
      BlockingDailyPoint(localDay: LocalDayKey('2026-02-02'), effectiveDuration: Duration(minutes: 30)),
    ]),
  );
}
