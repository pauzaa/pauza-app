import 'package:flutter/foundation.dart';
import 'package:pauza/src/features/friends/common/model/basic_user_dto.dart';

@immutable
final class LeaderboardEntryDto {
  const LeaderboardEntryDto({
    required this.rank,
    required this.user,
    this.currentStreakDays,
    this.totalFocusTimeMs,
  });

  factory LeaderboardEntryDto.fromJson(Map<String, Object?> json) =>
      LeaderboardEntryDto(
        rank: json['rank'] as int? ?? 0,
        user: BasicUserDto.fromJson(
          json['user'] as Map<String, Object?>? ?? const {},
        ),
        currentStreakDays: json['current_streak_days'] as int?,
        totalFocusTimeMs: json['total_focus_time_ms'] as int?,
      );

  final int rank;
  final BasicUserDto user;
  final int? currentStreakDays;
  final int? totalFocusTimeMs;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeaderboardEntryDto &&
          rank == other.rank &&
          user == other.user &&
          currentStreakDays == other.currentStreakDays &&
          totalFocusTimeMs == other.totalFocusTimeMs;

  @override
  int get hashCode =>
      Object.hash(rank, user, currentStreakDays, totalFocusTimeMs);

  @override
  String toString() =>
      'LeaderboardEntryDto(rank: $rank, user: $user, '
      'currentStreakDays: $currentStreakDays, '
      'totalFocusTimeMs: $totalFocusTimeMs)';
}
