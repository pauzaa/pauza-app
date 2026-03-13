import 'package:flutter/foundation.dart';

@immutable
final class LeaderboardRankDto {
  const LeaderboardRankDto({
    required this.rank,
    this.currentStreakDays,
    this.totalFocusTimeMs,
  });

  factory LeaderboardRankDto.fromJson(Map<String, Object?> json) =>
      LeaderboardRankDto(
        rank: json['rank'] as int? ?? 0,
        currentStreakDays: json['current_streak_days'] as int?,
        totalFocusTimeMs: json['total_focus_time_ms'] as int?,
      );

  final int rank;
  final int? currentStreakDays;
  final int? totalFocusTimeMs;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeaderboardRankDto &&
          rank == other.rank &&
          currentStreakDays == other.currentStreakDays &&
          totalFocusTimeMs == other.totalFocusTimeMs;

  @override
  int get hashCode => Object.hash(rank, currentStreakDays, totalFocusTimeMs);

  @override
  String toString() =>
      'LeaderboardRankDto(rank: $rank, '
      'currentStreakDays: $currentStreakDays, '
      'totalFocusTimeMs: $totalFocusTimeMs)';
}
