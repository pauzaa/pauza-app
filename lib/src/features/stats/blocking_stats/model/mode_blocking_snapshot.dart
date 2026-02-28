import 'package:equatable/equatable.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/foundation.dart';
import 'package:pauza/src/features/stats/blocking_stats/model/mode_blocking_breakdown.dart';

/// A snapshot of blocking statistics grouped by mode for a time window.
@immutable
final class ModeBlockingSnapshot extends Equatable {
  const ModeBlockingSnapshot({required this.breakdowns});

  /// Per-mode breakdowns, sorted by total effective time descending.
  final IList<ModeBlockingBreakdown> breakdowns;

  /// Whether there are any mode breakdowns.
  bool get isEmpty => breakdowns.isEmpty;

  @override
  List<Object?> get props => <Object?>[breakdowns];
}
