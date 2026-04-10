import 'package:equatable/equatable.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/features/ai/addiction_check/model/addiction_check_request_dto.dart';
import 'package:pauza/src/features/ai/addiction_check/model/ai_app_usage_history_dto.dart';
import 'package:pauza/src/features/ai/addiction_check/model/ai_daily_screen_time_dto.dart';
import 'package:pauza/src/core/api_client/api_client.dart';
import 'package:pauza/src/features/ai/common/model/ai_app_usage_item_dto.dart';
import 'package:pauza/src/features/ai/data/ai_repository.dart';
import 'package:pauza/src/features/stats/usage_stats/data/stats_usage_repository.dart';
import 'package:pauza/src/core/common/local_day_extensions.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

part 'ai_addiction_check_event.dart';
part 'ai_addiction_check_state.dart';

class AiAddictionCheckBloc extends Bloc<AiAddictionCheckEvent, AiAddictionCheckState> {
  AiAddictionCheckBloc({required AiRepository aiRepository, required StatsUsageRepository usageRepository})
    : _aiRepository = aiRepository,
      _usageRepository = usageRepository,
      super(const AiAddictionCheckState()) {
    on<AiAddictionCheckRequested>(_onRequested);
  }

  final AiRepository _aiRepository;
  final StatsUsageRepository _usageRepository;

  Future<void> _onRequested(AiAddictionCheckRequested event, Emitter<AiAddictionCheckState> emit) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearAnalysis: true));

    try {
      final now = DateTime.now();
      final days = List<DateTime>.generate(7, (i) => now.subtract(Duration(days: i)));

      final results = await Future.wait(days.map(_fetchDayData));

      final appUsageHistory = results.map((r) => r.$1).toIList();
      final dailyScreenTimeHistory = results.map((r) => r.$2).toIList();

      final request = AddictionCheckRequestDto(
        appUsageHistory: appUsageHistory,
        dailyScreenTimeHistory: dailyScreenTimeHistory,
      );

      final analysis = await _aiRepository.checkAddiction(request);
      emit(state.copyWith(isLoading: false, analysis: analysis));
    } on ApiError catch (error) {
      emit(state.copyWith(isLoading: false, error: error));
    } on Object catch (error) {
      emit(state.copyWith(isLoading: false, error: ApiUnknownError(error)));
    }
  }

  Future<(AiAppUsageHistoryDto, AiDailyScreenTimeDto)> _fetchDayData(DateTime day) async {
    final window = DateTimeRange(start: day.dayStart, end: day.dayEnd);
    final snapshot = await _usageRepository.getUsageSnapshot(window: window);
    final dateStr = day.localDayKey;

    var unlockCount = 0;
    try {
      final deviceEvents = await _usageRepository.getDeviceEventSnapshot(window: window);
      unlockCount = deviceEvents.unlockCount;
    } on Object catch (_) {
      // Device events not available on all platforms.
    }

    return (
      AiAppUsageHistoryDto(date: dateStr, apps: AiAppUsageItemDto.fromUsageEntries(snapshot.appUsageEntries)),
      AiDailyScreenTimeDto(
        date: dateStr,
        totalScreenTimeMs: snapshot.totalScreenTime.inMilliseconds,
        totalUnlocks: unlockCount,
      ),
    );
  }
}
