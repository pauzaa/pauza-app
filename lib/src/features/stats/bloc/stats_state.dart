import 'package:equatable/equatable.dart';
import 'package:pauza/src/core/common/pauza_platform.dart';
import 'package:pauza/src/features/stats/model/stats_date_window.dart';
import 'package:pauza/src/features/stats/model/stats_tab.dart';
import 'package:pauza/src/features/stats/model/usage_summary.dart';

final class StatsState extends Equatable {
  const StatsState({
    required this.platform,
    required this.selectedTab,
    required this.window,
    required this.maxDate,
    this.isLoading = false,
    this.summary,
    this.error,
    this.hasMissingPermission = false,
  });

  final PauzaPlatform platform;
  final StatsTab selectedTab;
  final StatsDateWindow window;
  final DateTime maxDate;
  final bool isLoading;
  final UsageSummary? summary;
  final Object? error;
  final bool hasMissingPermission;

  StatsState copyWith({
    StatsTab? selectedTab,
    StatsDateWindow? window,
    DateTime? maxDate,
    bool? isLoading,
    UsageSummary? summary,
    bool clearSummary = false,
    Object? error,
    bool clearError = false,
    bool? hasMissingPermission,
  }) {
    return StatsState(
      platform: platform,
      selectedTab: selectedTab ?? this.selectedTab,
      window: window ?? this.window,
      maxDate: maxDate ?? this.maxDate,
      isLoading: isLoading ?? this.isLoading,
      summary: clearSummary ? null : (summary ?? this.summary),
      error: clearError ? null : (error ?? this.error),
      hasMissingPermission: hasMissingPermission ?? this.hasMissingPermission,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    platform,
    selectedTab,
    window,
    maxDate,
    isLoading,
    summary,
    error,
    hasMissingPermission,
  ];
}
