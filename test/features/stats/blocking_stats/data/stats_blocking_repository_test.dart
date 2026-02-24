import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/core/local_database/local_database_service.dart';
import 'package:pauza/src/features/stats/blocking_stats/data/stats_blocking_repository.dart';
import 'package:pauza/src/features/streaks/common/model/streak_snapshot.dart';
import 'package:pauza/src/features/streaks/common/model/streak_types.dart';
import 'package:pauza/src/features/streaks/data/streaks_repository.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  group('StatsBlockingRepositoryImpl', () {
    test('excludes anomaly and in-progress sessions from metrics', () async {
      final database = _FakeLocalDatabase(
        sessionRows: <Map<String, Object?>>[
          {
            'started_at': _utc(2026, 2, 10, 10).millisecondsSinceEpoch,
            'ended_at': _utc(2026, 2, 10, 11).millisecondsSinceEpoch,
            'pause_count': 2,
            'total_paused_ms': const Duration(minutes: 10).inMilliseconds,
          },
        ],
        dailyRows: <Map<String, Object?>>[
          {'local_day': '2026-02-10', 'effective_ms': const Duration(minutes: 50).inMilliseconds},
        ],
      );

      final repository = StatsBlockingRepositoryImpl(
        localDatabase: database,
        streaksRepository: _FakeStreaksRepository(streakDays: 4, longestDays: 8),
      );

      final snapshot = await repository.getBlockingSnapshot(
        window: DateTimeRange(start: DateTime(2026, 2, 10), end: DateTime(2026, 2, 10)),
        nowLocal: DateTime(2026, 2, 10, 23),
      );

      expect(snapshot.completedSessionsCount, 1);
      expect(snapshot.averageRestrictionSessionDuration, const Duration(minutes: 50));
      expect(snapshot.averagePausesPerSession, 2);
      expect(snapshot.averagePauseDuration, const Duration(minutes: 5));
      expect(snapshot.currentStreakDays, 4);
      expect(snapshot.longestStreakDays, 8);
    });

    test('average pause duration is null when no pauses exist', () async {
      final database = _FakeLocalDatabase(
        sessionRows: <Map<String, Object?>>[
          {
            'started_at': _utc(2026, 2, 10, 10).millisecondsSinceEpoch,
            'ended_at': _utc(2026, 2, 10, 11).millisecondsSinceEpoch,
            'pause_count': 0,
            'total_paused_ms': 0,
          },
        ],
        dailyRows: const <Map<String, Object?>>[],
      );

      final repository = StatsBlockingRepositoryImpl(
        localDatabase: database,
        streaksRepository: _FakeStreaksRepository(streakDays: 0, longestDays: 0),
      );

      final snapshot = await repository.getBlockingSnapshot(
        window: DateTimeRange(start: DateTime(2026, 2, 10), end: DateTime(2026, 2, 10)),
        nowLocal: DateTime(2026, 2, 10),
      );

      expect(snapshot.averagePauseDuration, isNull);
      expect(snapshot.averagePausesPerSession, 0);
    });

    test('effective duration clamps to zero when paused exceeds span', () async {
      final database = _FakeLocalDatabase(
        sessionRows: <Map<String, Object?>>[
          {
            'started_at': _utc(2026, 2, 10, 10).millisecondsSinceEpoch,
            'ended_at': _utc(2026, 2, 10, 10, 10).millisecondsSinceEpoch,
            'pause_count': 1,
            'total_paused_ms': const Duration(minutes: 30).inMilliseconds,
          },
        ],
        dailyRows: const <Map<String, Object?>>[],
      );

      final repository = StatsBlockingRepositoryImpl(
        localDatabase: database,
        streaksRepository: _FakeStreaksRepository(streakDays: 0, longestDays: 0),
      );

      final snapshot = await repository.getBlockingSnapshot(
        window: DateTimeRange(start: DateTime(2026, 2, 10), end: DateTime(2026, 2, 10)),
        nowLocal: DateTime(2026, 2, 10),
      );

      expect(snapshot.totalEffectiveBlockedDuration, Duration.zero);
      expect(snapshot.longestRestrictionSessionDuration, Duration.zero);
    });

    test('uses ended_at range bounds for session query', () async {
      final database = _FakeLocalDatabase(
        sessionRows: const <Map<String, Object?>>[],
        dailyRows: const <Map<String, Object?>>[],
      );

      final repository = StatsBlockingRepositoryImpl(
        localDatabase: database,
        streaksRepository: _FakeStreaksRepository(streakDays: 0, longestDays: 0),
      );

      final range = DateTimeRange(start: DateTime(2026, 2, 1, 9), end: DateTime(2026, 2, 3, 16));

      await repository.getBlockingSnapshot(window: range, nowLocal: DateTime(2026, 2, 3, 23));

      expect(database.lastSessionRangeStart, DateTime(2026, 2).toUtc().millisecondsSinceEpoch);
      expect(database.lastSessionRangeEnd, DateTime(2026, 2, 3, 23, 59, 59, 999).toUtc().millisecondsSinceEpoch);
    });

    test('reads daily trend from streak_daily_aggregates table', () async {
      final database = _FakeLocalDatabase(
        sessionRows: const <Map<String, Object?>>[],
        dailyRows: <Map<String, Object?>>[
          {'local_day': '2026-02-01', 'effective_ms': const Duration(minutes: 11).inMilliseconds},
          {'local_day': '2026-02-02', 'effective_ms': const Duration(minutes: 17).inMilliseconds},
        ],
      );

      final repository = StatsBlockingRepositoryImpl(
        localDatabase: database,
        streaksRepository: _FakeStreaksRepository(streakDays: 0, longestDays: 0),
      );

      final snapshot = await repository.getBlockingSnapshot(
        window: DateTimeRange(start: DateTime(2026, 2), end: DateTime(2026, 2, 2)),
        nowLocal: DateTime(2026, 2, 2),
      );

      expect(snapshot.dailyTrend.length, 2);
      expect(snapshot.dailyTrend.first.effectiveDuration, const Duration(minutes: 11));
      expect(snapshot.dailyTrend.last.effectiveDuration, const Duration(minutes: 17));
      expect(database.dailyQueryCalled, isTrue);
    });
  });
}

DateTime _utc(int year, int month, int day, [int hour = 0, int minute = 0]) {
  return DateTime.utc(year, month, day, hour, minute);
}

final class _FakeLocalDatabase implements LocalDatabase {
  _FakeLocalDatabase({required this.sessionRows, required this.dailyRows});

  final List<Map<String, Object?>> sessionRows;
  final List<Map<String, Object?>> dailyRows;

  int? lastSessionRangeStart;
  int? lastSessionRangeEnd;
  bool dailyQueryCalled = false;

  @override
  bool get isOpen => true;

  @override
  Future<void> close() async {}

  @override
  Future<void> open() async {}

  @override
  Future<List<Map<String, Object?>>> rawQuery(String sql, [List<Object?>? arguments]) async {
    if (sql.contains('FROM restriction_sessions')) {
      lastSessionRangeStart = arguments![0] as int;
      lastSessionRangeEnd = arguments[1] as int;
      return sessionRows;
    }

    if (sql.contains('FROM streak_daily_aggregates')) {
      dailyQueryCalled = true;
      return dailyRows;
    }

    throw UnsupportedError('Unsupported rawQuery: $sql');
  }

  @override
  Future<T> read<T>(Future<T> Function(DatabaseExecutor database) action) {
    throw UnsupportedError('Not used in tests.');
  }

  @override
  Future<T> transaction<T>(Future<T> Function(Transaction transaction) action) {
    throw UnsupportedError('Not used in tests.');
  }

  @override
  Future<T> write<T>(Future<T> Function(DatabaseExecutor database) action) {
    throw UnsupportedError('Not used in tests.');
  }

  @override
  Future<int> rawDelete(String sql, [List<Object?>? arguments]) {
    throw UnsupportedError('Not used in tests.');
  }

  @override
  Future<int> rawInsert(String sql, [List<Object?>? arguments]) {
    throw UnsupportedError('Not used in tests.');
  }

  @override
  Future<int> rawUpdate(String sql, [List<Object?>? arguments]) {
    throw UnsupportedError('Not used in tests.');
  }
}

final class _FakeStreaksRepository implements StreaksRepository {
  _FakeStreaksRepository({required this.streakDays, required this.longestDays});

  final int streakDays;
  final int longestDays;

  @override
  Future<StreakSnapshot> getGlobalSnapshot({required DateTime nowLocal}) async {
    return StreakSnapshot(
      asOfLocal: nowLocal,
      targetDurationPerDay: const Duration(minutes: 10),
      todayEffectiveDuration: Duration.zero,
      currentStreakDays: CurrentStreakDays(streakDays),
      bestStreakDays: BestStreakDays(longestDays),
    );
  }

  @override
  Future<void> refreshAggregates() async {}
}
