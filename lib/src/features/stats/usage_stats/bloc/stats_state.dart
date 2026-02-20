import 'package:equatable/equatable.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:pauza/src/features/stats/usage_stats/model/usage_summary.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

final class StatsState extends Equatable {
  const StatsState({
    required this.window,
    required this.usageStats,
    required this.maxDate,
    this.isLoading = false,
    this.summary,
    this.error,
  });

  final bool isLoading;
  final DateTimeRange window;
  final DateTime maxDate;
  final UsageSummary? summary;
  final Object? error;
  final IList<UsageStats> usageStats;

  bool get hasError => error != null;

  StatsState copyWith({
    DateTimeRange? window,
    IList<UsageStats>? usageStats,
    DateTime? maxDate,
    bool? isLoading,
    UsageSummary? summary,
    bool clearSummary = false,
    Object? error,
  }) {
    return StatsState(
      window: window ?? this.window,
      usageStats: usageStats ?? this.usageStats,
      maxDate: maxDate ?? this.maxDate,
      isLoading: isLoading ?? this.isLoading,
      summary: clearSummary ? null : (summary ?? this.summary),
      error: error,
    );
  }

  @override
  List<Object?> get props => <Object?>[window, usageStats, maxDate, isLoading, summary, error];
}
