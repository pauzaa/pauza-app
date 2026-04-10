import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:pauza/src/core/api_client/api_client.dart';
import 'package:pauza/src/features/ai/common/model/ai_app_usage_item_dto.dart';
import 'package:pauza/src/features/ai/data/ai_repository.dart';
import 'package:pauza/src/features/ai/focus_schedule/model/focus_schedule_request_dto.dart';
import 'package:pauza/src/features/stats/usage_stats/data/stats_usage_repository.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

part 'ai_focus_schedule_event.dart';
part 'ai_focus_schedule_state.dart';

const _defaultPreferredFocusHours = 4;

class AiFocusScheduleBloc extends Bloc<AiFocusScheduleEvent, AiFocusScheduleState> {
  AiFocusScheduleBloc({required AiRepository aiRepository, required StatsUsageRepository usageRepository})
    : _aiRepository = aiRepository,
      _usageRepository = usageRepository,
      super(const AiFocusScheduleState()) {
    on<AiFocusScheduleRequested>(_onRequested);
  }

  final AiRepository _aiRepository;
  final StatsUsageRepository _usageRepository;

  Future<void> _onRequested(AiFocusScheduleRequested event, Emitter<AiFocusScheduleState> emit) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearAnalysis: true));

    try {
      final now = DateTime.now();
      final window = DateTimeRange(start: now.dayStart.subtract(const Duration(days: 6)), end: now.dayEnd);
      final snapshot = await _usageRepository.getUsageSnapshot(window: window);

      final request = FocusScheduleRequestDto(
        appUsage: AiAppUsageItemDto.fromUsageEntries(snapshot.appUsageEntries),
        preferredFocusHours: _defaultPreferredFocusHours,
        timezone: (await FlutterTimezone.getLocalTimezone()).identifier,
      );

      final analysis = await _aiRepository.suggestFocusSchedule(request);
      emit(state.copyWith(isLoading: false, analysis: analysis));
    } on ApiError catch (error) {
      emit(state.copyWith(isLoading: false, error: error));
    } on Object catch (error) {
      emit(state.copyWith(isLoading: false, error: ApiUnknownError(error)));
    }
  }
}
