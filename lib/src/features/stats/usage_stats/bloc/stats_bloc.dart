import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:pauza/src/core/common/extensions.dart';
import 'package:pauza/src/core/common/pauza_platform.dart';
import 'package:pauza/src/features/stats/usage_stats/bloc/stats_event.dart';
import 'package:pauza/src/features/stats/usage_stats/bloc/stats_state.dart';
import 'package:pauza/src/features/stats/usage_stats/data/stats_usage_repository.dart';
import 'package:pauza/src/features/stats/usage_stats/model/app_engagement_insight.dart';
import 'package:pauza/src/features/stats/usage_stats/model/device_usage_insights.dart';
import 'package:pauza/src/features/stats/usage_stats/model/stats_section_status.dart';
import 'package:pauza/src/features/stats/usage_stats/model/usage_summary.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class StatsBloc extends Bloc<StatsEvent, StatsState> {
  StatsBloc({
    required StatsUsageRepository usageRepository,
    required this.platform,
    DateTimeRange? initialRange,
    DateTime? maxDate,
  }) : _usageRepository = usageRepository,
       super(
         StatsState(
           window: initialRange ?? DateTime.now().pastWeek,
           maxDate: maxDate ?? DateTime.now().dayEnd,
           usageStats: const IList.empty(),
           topEngagementApps: const IList.empty(),
           hourlyHeatmap: const IMap.empty(),
         ),
       ) {
    on<StatsStarted>(_onStarted);
    on<StatsDateRangePicked>(_onDateRangePicked);
    on<StatsRefreshRequested>(_onRefreshRequested);
  }

  final StatsUsageRepository _usageRepository;
  final PauzaPlatform platform;

  Future<void> _onStarted(StatsStarted event, Emitter<StatsState> emit) async {
    await _loadUsage(emit);
  }

  Future<void> _onDateRangePicked(StatsDateRangePicked event, Emitter<StatsState> emit) async {
    final picked = DateTimeRange(start: event.range.start.dayStart, end: event.range.end.dayEnd);
    emit(state.copyWith(window: picked));
    await _loadUsage(emit);
  }

  Future<void> _onRefreshRequested(StatsRefreshRequested event, Emitter<StatsState> emit) async {
    await _loadUsage(emit);
  }

  Future<void> _loadUsage(Emitter<StatsState> emit) async {
    if (platform == PauzaPlatform.ios) {
      return;
    }

    emit(
      state.copyWith(
        isLoading: true,
        clearError: true,
        deviceInsightsStatus: StatsSectionStatus.loading,
        topEngagementStatus: StatsSectionStatus.loading,
        heatmapStatus: StatsSectionStatus.loading,
        clearDeviceInsights: true,
        clearDeviceInsightsError: true,
        clearTopEngagementError: true,
        clearHeatmapError: true,
        topEngagementApps: const IList.empty(),
        hourlyHeatmap: const IMap.empty(),
      ),
    );

    try {
      final currentUsage = await _usageRepository.getUsageStats(start: state.window.start, end: state.window.end);
      final dailyDurations = await _usageRepository.getDailyUsageDurations(start: state.window.start, end: state.window.end);

      final previousWindow = state.window.shiftByInclusiveRange(-state.window.inclusiveDays);
      final previousUsage = await _usageRepository.getUsageStats(start: previousWindow.start, end: previousWindow.end);

      emit(
        state.copyWith(
          isLoading: false,
          clearError: true,
          summary: UsageSummary.buildSummary(
            current: currentUsage,
            previous: previousUsage,
            window: state.window,
            dailyDurations: dailyDurations,
          ),
          // usageStats is already sorted by totalDuration descending from the repository.
          usageStats: currentUsage,
        ),
      );

      final deviceFuture = _captureOutcome<DeviceUsageInsights>(() {
        return _usageRepository.getDeviceUsageInsights(start: state.window.start, end: state.window.end);
      });
      final topEngagementFuture = _captureOutcome<IList<AppEngagementInsight>>(() {
        return _usageRepository.getTopAppEngagementInsights(start: state.window.start, end: state.window.end);
      });
      final heatmapFuture = _captureOutcome<IMap<int, Duration>>(() {
        return _usageRepository.getHourlyScreenTimeHeatmap(start: state.window.start, end: state.window.end);
      });

      final deviceOutcome = await deviceFuture;
      final topEngagementOutcome = await topEngagementFuture;
      final heatmapOutcome = await heatmapFuture;

      if (deviceOutcome case _LoadFailure(error: final PauzaMissingPermissionError e)) {
        throw e;
      }
      if (topEngagementOutcome case _LoadFailure(error: final PauzaMissingPermissionError e)) {
        throw e;
      }
      if (heatmapOutcome case _LoadFailure(error: final PauzaMissingPermissionError e)) {
        throw e;
      }

      emit(
        state.copyWith(
          deviceInsights: switch (deviceOutcome) {
            _LoadSuccess(:final data) => data,
            _ => null,
          },
          clearDeviceInsights: deviceOutcome is! _LoadSuccess,
          topEngagementApps: switch (topEngagementOutcome) {
            _LoadSuccess(:final data) => data,
            _ => const IList.empty(),
          },
          hourlyHeatmap: switch (heatmapOutcome) {
            _LoadSuccess(:final data) => data,
            _ => const IMap.empty(),
          },
          deviceInsightsStatus: _resolveDeviceInsightsStatus(deviceOutcome),
          topEngagementStatus: _resolveTopEngagementStatus(topEngagementOutcome),
          heatmapStatus: _resolveHeatmapStatus(heatmapOutcome),
          deviceInsightsError: switch (deviceOutcome) {
            _LoadFailure(:final error) => error,
            _ => null,
          },
          clearDeviceInsightsError: deviceOutcome is _LoadSuccess,
          topEngagementError: switch (topEngagementOutcome) {
            _LoadFailure(:final error) => error,
            _ => null,
          },
          clearTopEngagementError: topEngagementOutcome is _LoadSuccess,
          heatmapError: switch (heatmapOutcome) {
            _LoadFailure(:final error) => error,
            _ => null,
          },
          clearHeatmapError: heatmapOutcome is _LoadSuccess,
        ),
      );
    } on Object catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          error: error,
          clearSummary: true,
          clearDeviceInsights: true,
          clearDeviceInsightsError: true,
          clearTopEngagementError: true,
          clearHeatmapError: true,
          topEngagementApps: const IList.empty(),
          hourlyHeatmap: const IMap.empty(),
          deviceInsightsStatus: StatsSectionStatus.initial,
          topEngagementStatus: StatsSectionStatus.initial,
          heatmapStatus: StatsSectionStatus.initial,
        ),
      );
    }
  }

  Future<_LoadOutcome<T>> _captureOutcome<T>(Future<T> Function() loader) async {
    try {
      return _LoadSuccess<T>(await loader());
    } on Object catch (error) {
      return _LoadFailure<T>(error);
    }
  }

  StatsSectionStatus _resolveDeviceInsightsStatus(_LoadOutcome<DeviceUsageInsights> outcome) {
    return switch (outcome) {
      _LoadFailure() => StatsSectionStatus.failure,
      _LoadSuccess(:final data) => () {
        final isEmpty =
            data.unlockCount == 0 &&
            data.pickupCount == 0 &&
            data.screenOnDuration == Duration.zero &&
            data.unlockedDuration == Duration.zero;
        return isEmpty ? StatsSectionStatus.empty : StatsSectionStatus.success;
      }(),
    };
  }

  StatsSectionStatus _resolveTopEngagementStatus(_LoadOutcome<IList<AppEngagementInsight>> outcome) {
    return switch (outcome) {
      _LoadFailure() => StatsSectionStatus.failure,
      _LoadSuccess(:final data) => data.isEmpty ? StatsSectionStatus.empty : StatsSectionStatus.success,
    };
  }

  StatsSectionStatus _resolveHeatmapStatus(_LoadOutcome<IMap<int, Duration>> outcome) {
    return switch (outcome) {
      _LoadFailure() => StatsSectionStatus.failure,
      _LoadSuccess(:final data) =>
        data.values.every((duration) => duration == Duration.zero)
            ? StatsSectionStatus.empty
            : StatsSectionStatus.success,
    };
  }
}

sealed class _LoadOutcome<T> {
  const _LoadOutcome();
}

final class _LoadSuccess<T> extends _LoadOutcome<T> {
  const _LoadSuccess(this.data);
  final T data;
}

final class _LoadFailure<T> extends _LoadOutcome<T> {
  const _LoadFailure(this.error);
  final Object error;
}
