import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:pauza/src/core/common/model/local_day_key.dart';
import 'package:pauza/src/features/stats/blocking_stats/data/stats_blocking_repository.dart';
import 'package:pauza/src/features/stats/blocking_stats/model/blocking_daily_point.dart';
import 'package:pauza/src/features/stats/blocking_stats/model/blocking_stats_snapshot.dart';
import 'package:pauza/src/features/stats/blocking_stats/model/mode_blocking_breakdown.dart';
import 'package:pauza/src/features/stats/blocking_stats/model/mode_blocking_snapshot.dart';
import 'package:pauza/src/features/stats/blocking_stats/model/session_source.dart';
import 'package:pauza/src/features/stats/blocking_stats/model/source_blocking_breakdown.dart';
import 'package:pauza/src/features/stats/blocking_stats/model/source_blocking_snapshot.dart';

final class MockStatsBlockingRepository implements StatsBlockingRepository {
  const MockStatsBlockingRepository();

  @override
  Future<BlockingStatsSnapshot> getBlockingSnapshot({required DateTimeRange window, required DateTime nowLocal}) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    return BlockingStatsSnapshot(
      currentStreakDays: 12,
      longestStreakDays: 28,
      averageRestrictionSessionDuration: const Duration(minutes: 45),
      longestRestrictionSessionDuration: const Duration(hours: 2, minutes: 15),
      averagePausesPerSession: 1.3,
      averagePauseDuration: const Duration(minutes: 4, seconds: 30),
      completedSessionsCount: 87,
      totalEffectiveBlockedDuration: const Duration(hours: 65, minutes: 15),
      totalPausedDuration: const Duration(hours: 5, minutes: 40),
      dailyTrend: const <BlockingDailyPoint>[
        BlockingDailyPoint(localDay: LocalDayKey('2026-03-16'), effectiveDuration: Duration(hours: 1, minutes: 20)),
        BlockingDailyPoint(localDay: LocalDayKey('2026-03-17'), effectiveDuration: Duration(hours: 2, minutes: 5)),
        BlockingDailyPoint(localDay: LocalDayKey('2026-03-18'), effectiveDuration: Duration(hours: 1, minutes: 45)),
        BlockingDailyPoint(localDay: LocalDayKey('2026-03-19'), effectiveDuration: Duration(minutes: 55)),
        BlockingDailyPoint(localDay: LocalDayKey('2026-03-20'), effectiveDuration: Duration(hours: 2, minutes: 30)),
        BlockingDailyPoint(localDay: LocalDayKey('2026-03-21'), effectiveDuration: Duration(hours: 1, minutes: 10)),
        BlockingDailyPoint(localDay: LocalDayKey('2026-03-22'), effectiveDuration: Duration(hours: 1, minutes: 50)),
      ].toIList(),
    );
  }

  @override
  Future<ModeBlockingSnapshot> getModeBreakdown({required DateTimeRange window}) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    return ModeBlockingSnapshot(
      breakdowns: const <ModeBlockingBreakdown>[
        ModeBlockingBreakdown(
          modeId: 'mode_deep_focus',
          modeTitle: 'Deep Focus',
          completedSessionsCount: 42,
          totalEffectiveBlockedDuration: Duration(hours: 35, minutes: 20),
          averageRestrictionSessionDuration: Duration(minutes: 50),
        ),
        ModeBlockingBreakdown(
          modeId: 'mode_study',
          modeTitle: 'Study Mode',
          completedSessionsCount: 31,
          totalEffectiveBlockedDuration: Duration(hours: 22, minutes: 45),
          averageRestrictionSessionDuration: Duration(minutes: 44),
        ),
        ModeBlockingBreakdown(
          modeId: 'mode_sleep',
          modeTitle: 'Sleep',
          completedSessionsCount: 14,
          totalEffectiveBlockedDuration: Duration(hours: 7, minutes: 10),
          averageRestrictionSessionDuration: Duration(minutes: 30),
        ),
      ].toIList(),
    );
  }

  @override
  Future<SourceBlockingSnapshot> getSourceBreakdown({required DateTimeRange window}) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    return SourceBlockingSnapshot(
      breakdowns: const <SourceBlockingBreakdown>[
        SourceBlockingBreakdown(
          source: SessionSource.manual,
          completedSessionsCount: 58,
          totalEffectiveBlockedDuration: Duration(hours: 43, minutes: 30),
          averageRestrictionSessionDuration: Duration(minutes: 45),
        ),
        SourceBlockingBreakdown(
          source: SessionSource.schedule,
          completedSessionsCount: 29,
          totalEffectiveBlockedDuration: Duration(hours: 21, minutes: 45),
          averageRestrictionSessionDuration: Duration(minutes: 45),
        ),
      ].toIList(),
    );
  }
}
