import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/core/api_client/api_client.dart';
import 'package:pauza/src/features/ai/data/ai_repository.dart';

part 'ai_usage_analysis_event.dart';
part 'ai_usage_analysis_state.dart';

class AiUsageAnalysisBloc extends Bloc<AiUsageAnalysisEvent, AiUsageAnalysisState> {
  AiUsageAnalysisBloc({required AiRepository aiRepository})
    : _aiRepository = aiRepository,
      super(const AiUsageAnalysisState()) {
    on<AiUsageAnalysisRequested>(_onRequested);
  }

  final AiRepository _aiRepository;

  Future<void> _onRequested(AiUsageAnalysisRequested event, Emitter<AiUsageAnalysisState> emit) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearAnalysis: true));

    try {
      final analysis = await _aiRepository.analyzeUsage(window: event.window);
      emit(state.copyWith(isLoading: false, analysis: analysis));
    } on ApiError catch (error) {
      emit(state.copyWith(isLoading: false, error: error));
    } on Object catch (error) {
      emit(state.copyWith(isLoading: false, error: ApiUnknownError(error)));
    }
  }
}
