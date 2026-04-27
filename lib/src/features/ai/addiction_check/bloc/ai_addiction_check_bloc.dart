import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/core/api_client/api_client.dart';
import 'package:pauza/src/features/ai/data/ai_repository.dart';

part 'ai_addiction_check_event.dart';
part 'ai_addiction_check_state.dart';

class AiAddictionCheckBloc extends Bloc<AiAddictionCheckEvent, AiAddictionCheckState> {
  AiAddictionCheckBloc({required AiRepository aiRepository})
    : _aiRepository = aiRepository,
      super(const AiAddictionCheckState()) {
    on<AiAddictionCheckRequested>(_onRequested);
  }

  final AiRepository _aiRepository;

  Future<void> _onRequested(AiAddictionCheckRequested event, Emitter<AiAddictionCheckState> emit) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearAnalysis: true));

    try {
      final analysis = await _aiRepository.checkAddiction();
      emit(state.copyWith(isLoading: false, analysis: analysis));
    } on ApiError catch (error) {
      emit(state.copyWith(isLoading: false, error: error));
    } on Object catch (error) {
      emit(state.copyWith(isLoading: false, error: ApiUnknownError(error)));
    }
  }
}
