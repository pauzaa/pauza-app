import 'package:equatable/equatable.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/core/common/extensions.dart';
import 'package:pauza/src/features/stats/usage_stats/data/stats_usage_repository.dart';
import 'package:pauza/src/features/stats/usage_stats/model/daily_usage_point.dart';
import 'package:pauza/src/features/stats/usage_stats/model/device_event_snapshot.dart';
import 'package:pauza/src/features/stats/usage_stats/model/usage_stats_snapshot.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

part 'stats_usage_event.dart';
part 'stats_usage_state.dart';

class StatsUsageBloc extends Bloc<StatsUsageEvent, StatsUsageState> {
  StatsUsageBloc({required StatsUsageRepository repository, DateTimeRange? initialRange, DateTime? maxDate})
    : _repository = repository,
      super(
        StatsUsageState(window: initialRange ?? DateTime.now().pastWeek, maxDate: maxDate ?? DateTime.now().dayEnd),
      ) {
    on<StatsUsageStarted>(_onStarted);
    on<StatsUsageDateRangePicked>(_onDateRangePicked);
    on<StatsUsageRefreshRequested>(_onRefreshRequested);
  }

  final StatsUsageRepository _repository;

  Future<void> _onStarted(StatsUsageStarted event, Emitter<StatsUsageState> emit) async {
    await _load(emit);
  }

  Future<void> _onDateRangePicked(StatsUsageDateRangePicked event, Emitter<StatsUsageState> emit) async {
    final picked = DateTimeRange(start: event.range.start.dayStart, end: event.range.end.dayEnd);
    emit(
      state.copyWith(
        window: picked,
        isLoading: true,
        clearError: true,
        clearSnapshot: true,
        clearDailyTrend: true,
        clearDeviceEventSnapshot: true,
      ),
    );
    await _load(emit, skipLoadingEmit: true);
  }

  Future<void> _onRefreshRequested(StatsUsageRefreshRequested event, Emitter<StatsUsageState> emit) async {
    await _load(emit);
  }

  Future<void> _load(Emitter<StatsUsageState> emit, {bool skipLoadingEmit = false}) async {
    if (!skipLoadingEmit) {
      emit(state.copyWith(isLoading: true, clearError: true));
    }

    try {
      // Fire all three requests in parallel.
      final snapshotFuture = _repository.getUsageSnapshot(window: state.window);
      final trendFuture = _repository.getDailyUsageTrend(window: state.window);
      final deviceEventFuture = _repository.getDeviceEventSnapshot(window: state.window);

      // Await the two required data sources concurrently.
      final (snapshot, trend) = await (snapshotFuture, trendFuture).wait;

      // Await device events gracefully – degrades on Android < 9 or iOS.
      DeviceEventSnapshot? deviceEvents;
      try {
        deviceEvents = await deviceEventFuture;
      } on Object catch (_) {
        // PauzaUnsupportedError on Android < 9, or platform errors on iOS.
        // Degrade gracefully: deviceEventSnapshot stays null.
      }

      emit(
        state.copyWith(
          isLoading: false,
          snapshot: snapshot,
          dailyTrend: trend,
          deviceEventSnapshot: deviceEvents,
          clearDeviceEventSnapshot: deviceEvents == null,
          clearError: true,
        ),
      );
    } on Object catch (error) {
      emit(state.copyWith(isLoading: false, error: error));
    }
  }
}
