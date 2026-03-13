import 'package:flutter/foundation.dart';

@immutable
final class DailyTrendDto {
  const DailyTrendDto({
    required this.localDay,
    required this.effectiveMs,
    required this.qualified,
    this.sessionCount = 0,
  });

  factory DailyTrendDto.fromJson(Map<String, Object?> json) => DailyTrendDto(
    localDay: json['local_day'] as String? ?? '',
    effectiveMs: json['effective_ms'] as int? ?? 0,
    qualified: json['qualified'] as bool? ?? false,
    sessionCount: json['session_count'] as int? ?? 0,
  );

  final String localDay;
  final int effectiveMs;
  final bool qualified;
  final int sessionCount;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyTrendDto &&
          localDay == other.localDay &&
          effectiveMs == other.effectiveMs &&
          qualified == other.qualified &&
          sessionCount == other.sessionCount;

  @override
  int get hashCode => Object.hash(localDay, effectiveMs, qualified, sessionCount);

  @override
  String toString() =>
      'DailyTrendDto(localDay: $localDay, effectiveMs: $effectiveMs, '
      'qualified: $qualified, sessionCount: $sessionCount)';
}
