import 'package:equatable/equatable.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:pauza/src/features/stats/usage_stats/model/app_engagement_insight.dart';
import 'package:pauza/src/features/stats/usage_stats/model/device_usage_insights.dart';
import 'package:pauza/src/features/stats/usage_stats/model/stats_section_status.dart';
import 'package:pauza/src/features/stats/usage_stats/model/usage_summary.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

final class StatsState extends Equatable {
  const StatsState({
    required this.window,
    required this.usageStats,
    required this.maxDate,
    required this.topEngagementApps,
    required this.hourlyHeatmap,
    this.isLoading = false,
    this.summary,
    this.error,
    this.deviceInsights,
    this.deviceInsightsStatus = StatsSectionStatus.initial,
    this.topEngagementStatus = StatsSectionStatus.initial,
    this.heatmapStatus = StatsSectionStatus.initial,
    this.deviceInsightsError,
    this.topEngagementError,
    this.heatmapError,
  });

  final bool isLoading;
  final DateTimeRange window;
  final DateTime maxDate;
  final UsageSummary? summary;
  final Object? error;
  final IList<UsageStats> usageStats;
  final DeviceUsageInsights? deviceInsights;
  final IList<AppEngagementInsight> topEngagementApps;
  final IMap<int, Duration> hourlyHeatmap;
  final StatsSectionStatus deviceInsightsStatus;
  final StatsSectionStatus topEngagementStatus;
  final StatsSectionStatus heatmapStatus;
  final Object? deviceInsightsError;
  final Object? topEngagementError;
  final Object? heatmapError;

  bool get hasError => error != null;

  StatsState copyWith({
    DateTimeRange? window,
    IList<UsageStats>? usageStats,
    DateTime? maxDate,
    IList<AppEngagementInsight>? topEngagementApps,
    IMap<int, Duration>? hourlyHeatmap,
    bool? isLoading,
    UsageSummary? summary,
    bool clearSummary = false,
    Object? error,
    bool clearError = false,
    DeviceUsageInsights? deviceInsights,
    bool clearDeviceInsights = false,
    StatsSectionStatus? deviceInsightsStatus,
    StatsSectionStatus? topEngagementStatus,
    StatsSectionStatus? heatmapStatus,
    Object? deviceInsightsError,
    bool clearDeviceInsightsError = false,
    Object? topEngagementError,
    bool clearTopEngagementError = false,
    Object? heatmapError,
    bool clearHeatmapError = false,
  }) {
    return StatsState(
      window: window ?? this.window,
      usageStats: usageStats ?? this.usageStats,
      maxDate: maxDate ?? this.maxDate,
      topEngagementApps: topEngagementApps ?? this.topEngagementApps,
      hourlyHeatmap: hourlyHeatmap ?? this.hourlyHeatmap,
      isLoading: isLoading ?? this.isLoading,
      summary: clearSummary ? null : (summary ?? this.summary),
      error: clearError ? null : (error ?? this.error),
      deviceInsights: clearDeviceInsights ? null : (deviceInsights ?? this.deviceInsights),
      deviceInsightsStatus: deviceInsightsStatus ?? this.deviceInsightsStatus,
      topEngagementStatus: topEngagementStatus ?? this.topEngagementStatus,
      heatmapStatus: heatmapStatus ?? this.heatmapStatus,
      deviceInsightsError: clearDeviceInsightsError ? null : (deviceInsightsError ?? this.deviceInsightsError),
      topEngagementError: clearTopEngagementError ? null : (topEngagementError ?? this.topEngagementError),
      heatmapError: clearHeatmapError ? null : (heatmapError ?? this.heatmapError),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    window,
    usageStats,
    maxDate,
    isLoading,
    summary,
    error,
    deviceInsights,
    topEngagementApps,
    hourlyHeatmap,
    deviceInsightsStatus,
    topEngagementStatus,
    heatmapStatus,
    deviceInsightsError,
    topEngagementError,
    heatmapError,
  ];
}
