part of 'ai_focus_schedule_bloc.dart';

final class AiFocusScheduleState extends Equatable {
  const AiFocusScheduleState({this.isLoading = false, this.analysis, this.error});

  final bool isLoading;
  final String? analysis;
  final Object? error;

  bool get hasError => error != null;
  bool get hasAnalysis => analysis != null;

  AiFocusScheduleState copyWith({
    bool? isLoading,
    String? analysis,
    bool clearAnalysis = false,
    Object? error,
    bool clearError = false,
  }) {
    return AiFocusScheduleState(
      isLoading: isLoading ?? this.isLoading,
      analysis: clearAnalysis ? null : (analysis ?? this.analysis),
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => <Object?>[isLoading, analysis, error];
}
