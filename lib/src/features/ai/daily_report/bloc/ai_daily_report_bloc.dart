import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/core/api_client/api_client.dart';
import 'package:pauza/src/features/ai/data/ai_repository.dart';

part 'ai_daily_report_event.dart';
part 'ai_daily_report_state.dart';

class AiDailyReportBloc extends Bloc<AiDailyReportEvent, AiDailyReportState> {
  AiDailyReportBloc({required AiRepository aiRepository})
    : _aiRepository = aiRepository,
      super(const AiDailyReportState()) {
    on<AiDailyReportRequested>(_onRequested);
  }

  final AiRepository _aiRepository;

  Future<void> _onRequested(AiDailyReportRequested event, Emitter<AiDailyReportState> emit) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearAnalysis: true));

    try {
      final analysis = await _aiRepository.generateDailyReport();
      emit(state.copyWith(isLoading: false, analysis: analysis));
    } on ApiError catch (error) {
      emit(state.copyWith(isLoading: false, error: error));
    } on Object catch (error) {
      emit(state.copyWith(isLoading: false, error: ApiUnknownError(error)));
    }
  }
}
