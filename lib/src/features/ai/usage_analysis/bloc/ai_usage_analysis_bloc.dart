import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/core/api_client/api_client.dart';
import 'package:pauza/src/features/ai/common/model/ai_app_usage_item_dto.dart';
import 'package:pauza/src/features/ai/data/ai_repository.dart';
import 'package:pauza/src/features/ai/usage_analysis/model/usage_analysis_request_dto.dart';
import 'package:pauza/src/features/stats/usage_stats/data/stats_usage_repository.dart';

part 'ai_usage_analysis_event.dart';
part 'ai_usage_analysis_state.dart';

class AiUsageAnalysisBloc extends Bloc<AiUsageAnalysisEvent, AiUsageAnalysisState> {
  AiUsageAnalysisBloc({required AiRepository aiRepository, required StatsUsageRepository usageRepository})
    : _aiRepository = aiRepository,
      _usageRepository = usageRepository,
      super(const AiUsageAnalysisState()) {
    on<AiUsageAnalysisRequested>(_onRequested);
  }

  final AiRepository _aiRepository;
  final StatsUsageRepository _usageRepository;

  Future<void> _onRequested(AiUsageAnalysisRequested event, Emitter<AiUsageAnalysisState> emit) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearAnalysis: true));

    try {
      final window = event.window;

      final snapshotFuture = _usageRepository.getUsageSnapshot(window: window);
      final deviceEventFuture = _usageRepository.getDeviceEventSnapshot(window: window);

      final snapshot = await snapshotFuture;

      int? unlockCount;
      try {
        final deviceEvents = await deviceEventFuture;
        unlockCount = deviceEvents.unlockCount;
      } on Object catch (_) {
        // Device events not available on all platforms.
      }

      final windowDays = window.end.difference(window.start).inDays + 1;
      final request = UsageAnalysisRequestDto(
        period: windowDays > 1 ? 'weekly' : 'daily',
        appUsage: AiAppUsageItemDto.fromUsageEntries(snapshot.appUsageEntries),
        totalScreenTimeMs: snapshot.totalScreenTime.inMilliseconds,
        totalUnlocks: unlockCount,
      );

      final analysis = await _aiRepository.analyzeUsage(request);
      emit(state.copyWith(isLoading: false, analysis: analysis));
    } on ApiError catch (error) {
      emit(state.copyWith(isLoading: false, error: error));
    } on Object catch (error) {
      emit(state.copyWith(isLoading: false, error: ApiUnknownError(error)));
    }
  }
}
