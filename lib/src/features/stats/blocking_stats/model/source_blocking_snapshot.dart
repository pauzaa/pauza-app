import 'package:equatable/equatable.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/foundation.dart';
import 'package:pauza/src/features/stats/blocking_stats/model/source_blocking_breakdown.dart';

/// A snapshot of blocking statistics grouped by session source for a time window.
@immutable
final class SourceBlockingSnapshot extends Equatable {
  const SourceBlockingSnapshot({required this.breakdowns});

  /// Per-source breakdowns (manual vs scheduled).
  final IList<SourceBlockingBreakdown> breakdowns;

  /// Whether there are any source breakdowns.
  bool get isEmpty => breakdowns.isEmpty;

  @override
  List<Object?> get props => <Object?>[breakdowns];
}
