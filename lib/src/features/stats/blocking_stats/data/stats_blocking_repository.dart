import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:pauza/src/core/local_database/local_database.dart';
import 'package:pauza/src/features/stats/blocking_stats/model/blocking_daily_point.dart';
import 'package:pauza/src/features/stats/blocking_stats/model/blocking_stats_snapshot.dart';
import 'package:pauza/src/features/streaks/common/model/streak_extensions.dart';
import 'package:pauza/src/features/streaks/common/model/streak_types.dart';
import 'package:pauza/src/features/streaks/data/streaks_repository.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

abstract interface class StatsBlockingRepository {
  Future<BlockingStatsSnapshot> getBlockingSnapshot({required DateTimeRange window, required DateTime nowLocal});
}

final class StatsBlockingRepositoryImpl implements StatsBlockingRepository {
  const StatsBlockingRepositoryImpl({
    required LocalDatabase localDatabase,
    required StreaksRepository streaksRepository,
  }) : _localDatabase = localDatabase,
       _streaksRepository = streaksRepository;

  final LocalDatabase _localDatabase;
  final StreaksRepository _streaksRepository;

  @override
  Future<BlockingStatsSnapshot> getBlockingSnapshot({required DateTimeRange window, required DateTime nowLocal}) async {
    final rangeStartLocal = window.start.dayStart;
    final rangeEndLocal = window.end.dayEnd;
    final rangeStartUtcMs = rangeStartLocal.toUtc().millisecondsSinceEpoch;
    final rangeEndUtcMs = rangeEndLocal.toUtc().millisecondsSinceEpoch;

    await _streaksRepository.refreshAggregates();
    final streakSnapshot = await _streaksRepository.getGlobalSnapshot(nowLocal: nowLocal);

    final sessionRows = await _localDatabase.rawQuery(
      '''
SELECT
  started_at,
  ended_at,
  pause_count,
  total_paused_ms
FROM restriction_sessions
WHERE integrity_status = 'ok'
  AND ended_at IS NOT NULL
  AND ended_at BETWEEN ? AND ?
''',
      [rangeStartUtcMs, rangeEndUtcMs],
    );

    var completedSessionsCount = 0;
    var totalPauseCount = 0;
    var totalPausedMs = 0;
    var totalEffectiveMs = 0;
    var longestEffectiveMs = 0;

    for (final row in sessionRows) {
      final startedAtMs = row['started_at'].intOrZero;
      final endedAtMs = row['ended_at'].intOrZero;
      final pauseCount = row['pause_count'].intOrZero;
      final pausedMs = row['total_paused_ms'].intOrZero;

      final sessionSpanMs = endedAtMs > startedAtMs ? endedAtMs - startedAtMs : 0;
      final effectiveMs = sessionSpanMs > pausedMs ? sessionSpanMs - pausedMs : 0;

      completedSessionsCount += 1;
      totalPauseCount += pauseCount;
      totalPausedMs += pausedMs;
      totalEffectiveMs += effectiveMs;

      if (effectiveMs > longestEffectiveMs) {
        longestEffectiveMs = effectiveMs;
      }
    }

    final dailyRows = await _localDatabase.rawQuery(
      '''
SELECT
  local_day,
  effective_ms
FROM streak_daily_aggregates
WHERE local_day BETWEEN ? AND ?
ORDER BY local_day ASC
''',
      [LocalDayKey.fromDateTime(rangeStartLocal).dbValue, LocalDayKey.fromDateTime(rangeEndLocal).dbValue],
    );

    final dailyTrend = dailyRows.map((row) {
      return BlockingDailyPoint(
        localDay: LocalDayKey.fromDb(row['local_day'] as String),
        effectiveDuration: Duration(milliseconds: row['effective_ms'].intOrZero),
      );
    }).toIList();

    final averageSessionDuration = completedSessionsCount == 0
        ? null
        : Duration(milliseconds: totalEffectiveMs ~/ completedSessionsCount);
    final longestSessionDuration = completedSessionsCount == 0 ? null : Duration(milliseconds: longestEffectiveMs);
    final averagePausesPerSession = completedSessionsCount == 0 ? null : totalPauseCount / completedSessionsCount;
    final averagePauseDuration = totalPauseCount == 0 ? null : Duration(milliseconds: totalPausedMs ~/ totalPauseCount);

    return BlockingStatsSnapshot(
      currentStreakDays: streakSnapshot.currentStreakDays.value,
      longestStreakDays: streakSnapshot.bestStreakDays.value,
      averageRestrictionSessionDuration: averageSessionDuration,
      longestRestrictionSessionDuration: longestSessionDuration,
      averagePausesPerSession: averagePausesPerSession,
      averagePauseDuration: averagePauseDuration,
      completedSessionsCount: completedSessionsCount,
      totalEffectiveBlockedDuration: Duration(milliseconds: totalEffectiveMs),
      totalPausedDuration: Duration(milliseconds: totalPausedMs),
      dailyTrend: dailyTrend,
    );
  }
}
