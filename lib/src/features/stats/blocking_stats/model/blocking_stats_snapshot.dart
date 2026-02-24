import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:pauza/src/features/stats/blocking_stats/model/blocking_daily_point.dart';

@immutable
final class BlockingStatsSnapshot extends Equatable {
  const BlockingStatsSnapshot({
    required this.currentStreakDays,
    required this.longestStreakDays,
    required this.averageRestrictionSessionDuration,
    required this.longestRestrictionSessionDuration,
    required this.averagePausesPerSession,
    required this.averagePauseDuration,
    required this.completedSessionsCount,
    required this.totalEffectiveBlockedDuration,
    required this.totalPausedDuration,
    required this.dailyTrend,
  });

  final int currentStreakDays;
  final int longestStreakDays;
  final Duration? averageRestrictionSessionDuration;
  final Duration? longestRestrictionSessionDuration;
  final double? averagePausesPerSession;
  final Duration? averagePauseDuration;
  final int completedSessionsCount;
  final Duration totalEffectiveBlockedDuration;
  final Duration totalPausedDuration;
  final IList<BlockingDailyPoint> dailyTrend;

  bool get hasSessions => completedSessionsCount > 0;
  bool get isEmpty => !hasSessions && dailyTrend.isEmpty;

  @override
  List<Object?> get props => <Object?>[
    currentStreakDays,
    longestStreakDays,
    averageRestrictionSessionDuration,
    longestRestrictionSessionDuration,
    averagePausesPerSession,
    averagePauseDuration,
    completedSessionsCount,
    totalEffectiveBlockedDuration,
    totalPausedDuration,
    dailyTrend,
  ];
}
