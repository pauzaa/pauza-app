part of 'ai_usage_analysis_bloc.dart';

final class AiUsageAnalysisState extends Equatable {
  const AiUsageAnalysisState({this.isLoading = false, this.analysis, this.error});

  final bool isLoading;
  final String? analysis;
  final Object? error;

  bool get hasError => error != null;
  bool get hasAnalysis => analysis != null;

  AiUsageAnalysisState copyWith({
    bool? isLoading,
    String? analysis,
    bool clearAnalysis = false,
    Object? error,
    bool clearError = false,
  }) {
    return AiUsageAnalysisState(
      isLoading: isLoading ?? this.isLoading,
      analysis: clearAnalysis ? null : (analysis ?? this.analysis),
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => <Object?>[isLoading, analysis, error];
}
