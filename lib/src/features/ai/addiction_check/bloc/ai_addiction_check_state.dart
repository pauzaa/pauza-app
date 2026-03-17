part of 'ai_addiction_check_bloc.dart';

final class AiAddictionCheckState extends Equatable {
  const AiAddictionCheckState({this.isLoading = false, this.analysis, this.error});

  final bool isLoading;
  final String? analysis;
  final Object? error;

  bool get hasError => error != null;
  bool get hasAnalysis => analysis != null;

  AiAddictionCheckState copyWith({
    bool? isLoading,
    String? analysis,
    bool clearAnalysis = false,
    Object? error,
    bool clearError = false,
  }) {
    return AiAddictionCheckState(
      isLoading: isLoading ?? this.isLoading,
      analysis: clearAnalysis ? null : (analysis ?? this.analysis),
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => <Object?>[isLoading, analysis, error];
}
