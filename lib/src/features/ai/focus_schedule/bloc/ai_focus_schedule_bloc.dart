import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/core/api_client/api_client.dart';
import 'package:pauza/src/features/ai/data/ai_repository.dart';

part 'ai_focus_schedule_event.dart';
part 'ai_focus_schedule_state.dart';

class AiFocusScheduleBloc extends Bloc<AiFocusScheduleEvent, AiFocusScheduleState> {
  AiFocusScheduleBloc({required AiRepository aiRepository})
    : _aiRepository = aiRepository,
      super(const AiFocusScheduleState()) {
    on<AiFocusScheduleRequested>(_onRequested);
  }

  final AiRepository _aiRepository;

  Future<void> _onRequested(AiFocusScheduleRequested event, Emitter<AiFocusScheduleState> emit) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearAnalysis: true));

    try {
      final analysis = await _aiRepository.suggestFocusSchedule();
      emit(state.copyWith(isLoading: false, analysis: analysis));
    } on ApiError catch (error) {
      emit(state.copyWith(isLoading: false, error: error));
    } on Object catch (error) {
      emit(state.copyWith(isLoading: false, error: ApiUnknownError(error)));
    }
  }
}
