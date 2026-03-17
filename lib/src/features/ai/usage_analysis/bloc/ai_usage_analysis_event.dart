part of 'ai_usage_analysis_bloc.dart';

sealed class AiUsageAnalysisEvent {
  const AiUsageAnalysisEvent();
}

final class AiUsageAnalysisRequested extends AiUsageAnalysisEvent {
  const AiUsageAnalysisRequested({required this.window});

  final DateTimeRange window;
}
