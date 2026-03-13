import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
final class AiFocusSessionDto extends Equatable {
  const AiFocusSessionDto({
    required this.startedAt,
    required this.endedAt,
    required this.pauseCount,
    required this.effectiveMs,
  });

  /// Unix milliseconds when the session started.
  final int startedAt;

  /// Unix milliseconds when the session ended.
  final int endedAt;

  final int pauseCount;

  /// Effective focus time in milliseconds (excluding pauses).
  final int effectiveMs;

  Map<String, Object?> toJson() => <String, Object?>{
    'started_at': startedAt,
    'ended_at': endedAt,
    'pause_count': pauseCount,
    'effective_ms': effectiveMs,
  };

  @override
  List<Object?> get props => <Object?>[
    startedAt,
    endedAt,
    pauseCount,
    effectiveMs,
  ];

  @override
  String toString() =>
      'AiFocusSessionDto('
      'started: $startedAt, '
      'ended: $endedAt, '
      'pauses: $pauseCount, '
      'effective: ${effectiveMs}ms)';
}
