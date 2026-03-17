import 'dart:math' as math;

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:pauza/src/core/local_database/local_database.dart';
import 'package:pauza/src/features/stats/blocking_stats/model/blocking_daily_point.dart';
import 'package:pauza/src/features/stats/blocking_stats/model/blocking_stats_snapshot.dart';
import 'package:pauza/src/features/stats/blocking_stats/model/mode_blocking_breakdown.dart';
import 'package:pauza/src/features/stats/blocking_stats/model/mode_blocking_snapshot.dart';
import 'package:pauza/src/features/stats/blocking_stats/model/session_source.dart';
import 'package:pauza/src/features/stats/blocking_stats/model/source_blocking_breakdown.dart';
import 'package:pauza/src/features/stats/blocking_stats/model/source_blocking_snapshot.dart';
import 'package:pauza/src/core/common/local_day_extensions.dart';
import 'package:pauza/src/core/common/model/local_day_key.dart';
import 'package:pauza/src/features/streaks/common/model/streak_snapshot.dart';
import 'package:pauza/src/features/streaks/data/streaks_repository.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

// ---------------------------------------------------------------------------
// Interface
// ---------------------------------------------------------------------------

abstract interface class StatsBlockingRepository {
  /// Returns an aggregated blocking-stats snapshot for the given [window].
  Future<BlockingStatsSnapshot> getBlockingSnapshot({required DateTimeRange window, required DateTime nowLocal});

  /// Returns per-mode breakdown of blocking stats for the given [window].
  Future<ModeBlockingSnapshot> getModeBreakdown({required DateTimeRange window});

  /// Returns per-source (manual vs scheduled) breakdown for the given [window].
  Future<SourceBlockingSnapshot> getSourceBreakdown({required DateTimeRange window});
}

// ---------------------------------------------------------------------------
// Implementation
// ---------------------------------------------------------------------------

final class StatsBlockingRepositoryImpl implements StatsBlockingRepository {
  const StatsBlockingRepositoryImpl({
    required LocalDatabase localDatabase,
    required StreaksRepository streaksRepository,
  }) : _localDatabase = localDatabase,
       _streaksRepository = streaksRepository;

  final LocalDatabase _localDatabase;
  final StreaksRepository _streaksRepository;

  // -------------------------------------------------------------------------
  // Public API
  // -------------------------------------------------------------------------

  @override
  Future<BlockingStatsSnapshot> getBlockingSnapshot({required DateTimeRange window, required DateTime nowLocal}) async {
    final range = _UtcRange.fromWindow(window);

    // Independent data sources — fetch in parallel.
    final (streakSnapshot, sessionRows, dailyTrend) = await (
      _streaksRepository.getGlobalSnapshot(nowLocal: nowLocal),
      _querySessionRows(range),
      _queryDailyTrend(window),
    ).wait;

    final agg = _aggregateSessions(sessionRows, range: range);

    return _buildSnapshot(agg: agg, streakSnapshot: streakSnapshot, dailyTrend: dailyTrend);
  }

  @override
  Future<ModeBlockingSnapshot> getModeBreakdown({required DateTimeRange window}) async {
    final range = _UtcRange.fromWindow(window);

    final rows = await _localDatabase.rawQuery(
      '''
SELECT
  rs.mode_id,
  m.title AS mode_title,
  rs.started_at,
  rs.ended_at,
  rs.pause_count,
  rs.total_paused_ms
FROM restriction_sessions rs
LEFT JOIN modes m ON m.id = rs.mode_id
WHERE rs.integrity_status = 'ok'
  AND rs.started_at IS NOT NULL
  AND rs.ended_at IS NOT NULL
  AND rs.started_at <= ?
  AND rs.ended_at >= ?
''',
      [range.endUtcMs, range.startUtcMs],
    );

    // Group rows by mode_id, then aggregate each group.
    final grouped = <String, List<Map<String, Object?>>>{};
    final titles = <String, String>{};

    for (final row in rows) {
      final modeId = row['mode_id'] as String? ?? 'unknown';
      final modeTitle = row['mode_title'] as String? ?? modeId;
      (grouped[modeId] ??= []).add(row);
      titles.putIfAbsent(modeId, () => modeTitle);
    }

    final breakdowns = grouped.entries.map((entry) {
      final agg = _aggregateSessions(entry.value, range: range);
      final avgDuration = agg.completedCount == 0
          ? null
          : Duration(milliseconds: agg.totalEffectiveMs ~/ agg.completedCount);

      return ModeBlockingBreakdown(
        modeId: entry.key,
        modeTitle: titles[entry.key] ?? entry.key,
        completedSessionsCount: agg.completedCount,
        totalEffectiveBlockedDuration: Duration(milliseconds: agg.totalEffectiveMs),
        averageRestrictionSessionDuration: avgDuration,
      );
    }).toList()..sort((a, b) => b.totalEffectiveBlockedDuration.compareTo(a.totalEffectiveBlockedDuration));

    return ModeBlockingSnapshot(breakdowns: breakdowns.toIList());
  }

  @override
  Future<SourceBlockingSnapshot> getSourceBreakdown({required DateTimeRange window}) async {
    final range = _UtcRange.fromWindow(window);

    final rows = await _localDatabase.rawQuery(
      '''
SELECT
  source,
  started_at,
  ended_at,
  pause_count,
  total_paused_ms
FROM restriction_sessions
WHERE integrity_status = 'ok'
  AND started_at IS NOT NULL
  AND ended_at IS NOT NULL
  AND started_at <= ?
  AND ended_at >= ?
''',
      [range.endUtcMs, range.startUtcMs],
    );

    // Group rows by source, then aggregate each group.
    final grouped = <SessionSource, List<Map<String, Object?>>>{};

    for (final row in rows) {
      final source = SessionSource.fromDb(row['source']);
      if (source == null) continue;
      (grouped[source] ??= []).add(row);
    }

    final breakdowns = SessionSource.values.map((source) {
      final group = grouped[source];
      if (group == null || group.isEmpty) {
        return SourceBlockingBreakdown(
          source: source,
          completedSessionsCount: 0,
          totalEffectiveBlockedDuration: Duration.zero,
          averageRestrictionSessionDuration: null,
        );
      }
      final agg = _aggregateSessions(group, range: range);
      final avgDuration = agg.completedCount == 0
          ? null
          : Duration(milliseconds: agg.totalEffectiveMs ~/ agg.completedCount);

      return SourceBlockingBreakdown(
        source: source,
        completedSessionsCount: agg.completedCount,
        totalEffectiveBlockedDuration: Duration(milliseconds: agg.totalEffectiveMs),
        averageRestrictionSessionDuration: avgDuration,
      );
    }).toIList();

    return SourceBlockingSnapshot(breakdowns: breakdowns);
  }

  // -------------------------------------------------------------------------
  // Query helpers
  // -------------------------------------------------------------------------

  Future<List<Map<String, Object?>>> _querySessionRows(_UtcRange range) {
    return _localDatabase.rawQuery(
      '''
SELECT
  started_at,
  ended_at,
  pause_count,
  total_paused_ms
FROM restriction_sessions
WHERE integrity_status = 'ok'
  AND started_at IS NOT NULL
  AND ended_at IS NOT NULL
  AND started_at <= ?
  AND ended_at >= ?
''',
      [range.endUtcMs, range.startUtcMs],
    );
  }

  Future<IList<BlockingDailyPoint>> _queryDailyTrend(DateTimeRange window) async {
    final rangeStartLocal = window.start.dayStart;
    final rangeEndLocal = window.end.dayEnd;

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

    return dailyRows
        .map(
          (row) => BlockingDailyPoint(
            localDay: LocalDayKey.fromDb(row['local_day'] as String),
            effectiveDuration: Duration(milliseconds: row['effective_ms'].intOrZero),
          ),
        )
        .toIList();
  }

  // -------------------------------------------------------------------------
  // Aggregation helpers
  // -------------------------------------------------------------------------

  /// Iterates over raw session rows and produces an aggregate result
  /// clipped to the given UTC [range].
  _SessionAggregateResult _aggregateSessions(List<Map<String, Object?>> rows, {required _UtcRange range}) {
    var completedCount = 0;
    var totalPauseCount = 0;
    var totalPausedMs = 0;
    var totalEffectiveMs = 0;
    var longestEffectiveMs = 0;

    for (final row in rows) {
      final startedAtMs = row['started_at'].intOrZero;
      final endedAtMs = row['ended_at'].intOrZero;
      if (endedAtMs <= startedAtMs) continue;

      final overlapStartMs = math.max(startedAtMs, range.startUtcMs);
      final overlapEndMs = math.min(endedAtMs, range.endUtcMs);
      final overlapSpanMs = overlapEndMs - overlapStartMs;
      if (overlapSpanMs <= 0) continue;

      final sessionSpanMs = endedAtMs - startedAtMs;
      final pausedMs = row['total_paused_ms'].intOrZero;
      final clipped = _clippedPausedMs(pausedMs: pausedMs, overlapSpanMs: overlapSpanMs, sessionSpanMs: sessionSpanMs);
      final effectiveMs = overlapSpanMs - clipped;

      completedCount += 1;
      totalPauseCount += row['pause_count'].intOrZero;
      totalPausedMs += clipped;
      totalEffectiveMs += effectiveMs;
      longestEffectiveMs = math.max(longestEffectiveMs, effectiveMs);
    }

    return _SessionAggregateResult(
      completedCount: completedCount,
      totalPauseCount: totalPauseCount,
      totalPausedMs: totalPausedMs,
      totalEffectiveMs: totalEffectiveMs,
      longestEffectiveMs: longestEffectiveMs,
    );
  }

  /// Builds the final [BlockingStatsSnapshot] from pre-computed parts.
  BlockingStatsSnapshot _buildSnapshot({
    required _SessionAggregateResult agg,
    required StreakSnapshot streakSnapshot,
    required IList<BlockingDailyPoint> dailyTrend,
  }) {
    final avgSessionDuration = agg.completedCount == 0
        ? null
        : Duration(milliseconds: agg.totalEffectiveMs ~/ agg.completedCount);
    final longestSessionDuration = agg.completedCount == 0 ? null : Duration(milliseconds: agg.longestEffectiveMs);
    final avgPausesPerSession = agg.completedCount == 0 ? null : agg.totalPauseCount / agg.completedCount;
    final avgPauseDuration = agg.totalPauseCount == 0
        ? null
        : Duration(milliseconds: agg.totalPausedMs ~/ agg.totalPauseCount);

    return BlockingStatsSnapshot(
      currentStreakDays: streakSnapshot.currentStreakDays.value,
      longestStreakDays: streakSnapshot.bestStreakDays.value,
      averageRestrictionSessionDuration: avgSessionDuration,
      longestRestrictionSessionDuration: longestSessionDuration,
      averagePausesPerSession: avgPausesPerSession,
      averagePauseDuration: avgPauseDuration,
      completedSessionsCount: agg.completedCount,
      totalEffectiveBlockedDuration: Duration(milliseconds: agg.totalEffectiveMs),
      totalPausedDuration: Duration(milliseconds: agg.totalPausedMs),
      dailyTrend: dailyTrend,
    );
  }

  /// Proportionally clips paused milliseconds to the overlap window.
  ///
  /// When a session partially overlaps the requested range, the total paused
  /// time is scaled proportionally. The result is clamped to
  /// `[0, overlapSpanMs]`.
  int _clippedPausedMs({required int pausedMs, required int overlapSpanMs, required int sessionSpanMs}) {
    if (pausedMs <= 0 || overlapSpanMs <= 0 || sessionSpanMs <= 0) return 0;
    final estimated = (pausedMs * overlapSpanMs / sessionSpanMs).round();
    return estimated.clamp(0, overlapSpanMs);
  }
}

// ---------------------------------------------------------------------------
// Private helper types
// ---------------------------------------------------------------------------

/// Pre-computed UTC millisecond bounds for a [DateTimeRange].
final class _UtcRange {
  const _UtcRange({required this.startUtcMs, required this.endUtcMs});

  factory _UtcRange.fromWindow(DateTimeRange window) {
    return _UtcRange(
      startUtcMs: window.start.dayStart.toUtc().millisecondsSinceEpoch,
      endUtcMs: window.end.dayEnd.toUtc().millisecondsSinceEpoch,
    );
  }

  final int startUtcMs;
  final int endUtcMs;
}

/// Intermediate aggregation result from iterating session rows.
final class _SessionAggregateResult {
  const _SessionAggregateResult({
    required this.completedCount,
    required this.totalPauseCount,
    required this.totalPausedMs,
    required this.totalEffectiveMs,
    required this.longestEffectiveMs,
  });

  final int completedCount;
  final int totalPauseCount;
  final int totalPausedMs;
  final int totalEffectiveMs;
  final int longestEffectiveMs;
}
