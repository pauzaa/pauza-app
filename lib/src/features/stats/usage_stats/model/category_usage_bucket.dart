import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Aggregated usage for a single Android app category.
@immutable
final class CategoryUsageBucket extends Equatable {
  const CategoryUsageBucket({
    required this.category,
    required this.totalDuration,
    required this.appCount,
    required this.shareOfTotal,
  });

  /// Android category string (e.g. "Social", "Video").
  /// `null` represents uncategorized apps.
  final String? category;

  /// Combined foreground time of all apps in this category.
  final Duration totalDuration;

  /// Number of distinct apps that contributed to this bucket.
  final int appCount;

  /// Fraction of total screen time this category represents (0.0 - 1.0).
  final double shareOfTotal;

  @override
  List<Object?> get props => <Object?>[category, totalDuration, appCount, shareOfTotal];

  @override
  String toString() =>
      'CategoryUsageBucket(${category ?? 'uncategorized'}, '
      'duration: $totalDuration, '
      'apps: $appCount, '
      'share: ${(shareOfTotal * 100).toStringAsFixed(1)}%)';
}
