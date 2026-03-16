import 'package:flutter/foundation.dart';
import 'package:pauza/src/features/friends/common/model/basic_user_dto.dart';
import 'package:pauza/src/features/friends/common/model/daily_trend_dto.dart';

@immutable
final class FriendStatsDto {
  const FriendStatsDto({
    required this.user,
    required this.currentStreakDays,
    required this.longestStreakDays,
    required this.totalFocusTimeMs,
    required this.focusTimeTodayMs,
    required this.dailyTrends,
  });

  factory FriendStatsDto.fromJson(Map<String, Object?> json) {
    final stats = json['stats'] as Map<String, Object?>? ?? const {};
    final rawTrends = stats['daily_trends'] as List<Object?>?;
    return FriendStatsDto(
      user: BasicUserDto.fromJson(json['user'] as Map<String, Object?>? ?? const {}),
      currentStreakDays: stats['current_streak_days'] as int? ?? 0,
      longestStreakDays: stats['longest_streak_days'] as int? ?? 0,
      totalFocusTimeMs: stats['total_focus_time_ms'] as int? ?? 0,
      focusTimeTodayMs: stats['focus_time_today_ms'] as int? ?? 0,
      dailyTrends:
          rawTrends
              ?.map((e) => DailyTrendDto.fromJson(e as Map<String, Object?>? ?? const {}))
              .toList(growable: false) ??
          const [],
    );
  }

  final BasicUserDto user;
  final int currentStreakDays;
  final int longestStreakDays;
  final int totalFocusTimeMs;
  final int focusTimeTodayMs;
  final List<DailyTrendDto> dailyTrends;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FriendStatsDto &&
          user == other.user &&
          currentStreakDays == other.currentStreakDays &&
          longestStreakDays == other.longestStreakDays &&
          totalFocusTimeMs == other.totalFocusTimeMs &&
          focusTimeTodayMs == other.focusTimeTodayMs &&
          _listEquals(dailyTrends, other.dailyTrends);

  @override
  int get hashCode => Object.hash(
    user,
    currentStreakDays,
    longestStreakDays,
    totalFocusTimeMs,
    focusTimeTodayMs,
    Object.hashAll(dailyTrends),
  );

  @override
  String toString() =>
      'FriendStatsDto(user: $user, currentStreakDays: $currentStreakDays, '
      'longestStreakDays: $longestStreakDays, '
      'totalFocusTimeMs: $totalFocusTimeMs, '
      'focusTimeTodayMs: $focusTimeTodayMs, '
      'dailyTrends: $dailyTrends)';
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
