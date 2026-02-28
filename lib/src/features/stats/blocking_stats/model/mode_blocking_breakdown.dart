import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Aggregated blocking statistics for a single mode within a time window.
@immutable
final class ModeBlockingBreakdown extends Equatable {
  const ModeBlockingBreakdown({
    required this.modeId,
    required this.modeTitle,
    required this.completedSessionsCount,
    required this.totalEffectiveBlockedDuration,
    required this.averageRestrictionSessionDuration,
  });

  /// The unique identifier of the mode.
  final String modeId;

  /// The user-facing title of the mode.
  final String modeTitle;

  /// Number of completed sessions for this mode.
  final int completedSessionsCount;

  /// Total effective (non-paused) blocked time for this mode.
  final Duration totalEffectiveBlockedDuration;

  /// Average effective session duration for this mode, or `null` if no sessions.
  final Duration? averageRestrictionSessionDuration;

  @override
  List<Object?> get props => <Object?>[
    modeId,
    modeTitle,
    completedSessionsCount,
    totalEffectiveBlockedDuration,
    averageRestrictionSessionDuration,
  ];
}
