import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/core/api_client/api_client.dart';
import 'package:pauza/src/features/ai/common/model/ai_app_usage_item_dto.dart';
import 'package:pauza/src/features/ai/daily_report/model/daily_report_request_dto.dart';
import 'package:pauza/src/features/ai/data/ai_repository.dart';
import 'package:pauza/src/features/stats/usage_stats/data/stats_usage_repository.dart';
import 'package:pauza/src/core/common/local_day_extensions.dart';
import 'package:pauza/src/features/streaks/data/streaks_repository.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

part 'ai_daily_report_event.dart';
part 'ai_daily_report_state.dart';

class AiDailyReportBloc extends Bloc<AiDailyReportEvent, AiDailyReportState> {
  AiDailyReportBloc({
    required AiRepository aiRepository,
    required StatsUsageRepository usageRepository,
    required StreaksRepository streaksRepository,
  }) : _aiRepository = aiRepository,
       _usageRepository = usageRepository,
       _streaksRepository = streaksRepository,
       super(const AiDailyReportState()) {
    on<AiDailyReportRequested>(_onRequested);
  }

  final AiRepository _aiRepository;
  final StatsUsageRepository _usageRepository;
  final StreaksRepository _streaksRepository;

  Future<void> _onRequested(AiDailyReportRequested event, Emitter<AiDailyReportState> emit) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearAnalysis: true));

    try {
      final now = DateTime.now();
      final window = DateTimeRange(start: now.dayStart, end: now.dayEnd);

      final (snapshot, streakSnapshot) = await (
        _usageRepository.getUsageSnapshot(window: window),
        _streaksRepository.getGlobalSnapshot(nowLocal: now),
      ).wait;

      var screenOnTimeMs = snapshot.totalScreenTime.inMilliseconds;
      var unlockCount = 0;
      try {
        final deviceEvents = await _usageRepository.getDeviceEventSnapshot(window: window);
        screenOnTimeMs = deviceEvents.totalScreenOnTime.inMilliseconds;
        unlockCount = deviceEvents.unlockCount;
      } on Object catch (_) {
        // Device events not available on all platforms; fall back to sum-of-apps.
      }

      final request = DailyReportRequestDto(
        date: now.localDayKey,
        appUsage: AiAppUsageItemDto.fromUsageEntries(snapshot.appUsageEntries),
        totalScreenTimeMs: screenOnTimeMs,
        totalUnlocks: unlockCount > 0 ? unlockCount : null,
        streakDays: streakSnapshot.currentStreakDays.value > 0 ? streakSnapshot.currentStreakDays.value : null,
      );

      final analysis = await _aiRepository.generateDailyReport(request);
      emit(state.copyWith(isLoading: false, analysis: analysis));
    } on ApiError catch (error) {
      emit(state.copyWith(isLoading: false, error: error));
    } on Object catch (error) {
      emit(state.copyWith(isLoading: false, error: ApiUnknownError(error)));
    }
  }
}
