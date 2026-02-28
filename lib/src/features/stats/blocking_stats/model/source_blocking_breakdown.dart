import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:pauza/src/features/stats/blocking_stats/model/session_source.dart';

/// Aggregated blocking statistics for a single session source type
/// (manual or scheduled) within a time window.
@immutable
final class SourceBlockingBreakdown extends Equatable {
  const SourceBlockingBreakdown({
    required this.source,
    required this.completedSessionsCount,
    required this.totalEffectiveBlockedDuration,
    required this.averageRestrictionSessionDuration,
  });

  /// The session source type (manual or schedule).
  final SessionSource source;

  /// Number of completed sessions from this source.
  final int completedSessionsCount;

  /// Total effective (non-paused) blocked time from this source.
  final Duration totalEffectiveBlockedDuration;

  /// Average effective session duration from this source, or `null` if no sessions.
  final Duration? averageRestrictionSessionDuration;

  @override
  List<Object?> get props => <Object?>[
    source,
    completedSessionsCount,
    totalEffectiveBlockedDuration,
    averageRestrictionSessionDuration,
  ];
}
