import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:pauza/src/features/stats/usage_stats/model/usage_summary.dart';

final class StatsState extends Equatable {
  const StatsState({
    required this.window,
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

  bool get hasError => error != null;

  StatsState copyWith({
    DateTimeRange? window,
    DateTime? maxDate,
    bool? isLoading,
    UsageSummary? summary,
    bool clearSummary = false,
    Object? error,
  }) {
    return StatsState(
      window: window ?? this.window,
      maxDate: maxDate ?? this.maxDate,
      isLoading: isLoading ?? this.isLoading,
      summary: clearSummary ? null : (summary ?? this.summary),
      error: error,
    );
  }

  @override
  List<Object?> get props => <Object?>[window, maxDate, isLoading, summary, error];
}
