part of 'ai_daily_report_bloc.dart';

final class AiDailyReportState extends Equatable {
  const AiDailyReportState({this.isLoading = false, this.analysis, this.error});

  final bool isLoading;
  final String? analysis;
  final Object? error;

  bool get hasError => error != null;
  bool get hasAnalysis => analysis != null;

  AiDailyReportState copyWith({
    bool? isLoading,
    String? analysis,
    bool clearAnalysis = false,
    Object? error,
    bool clearError = false,
  }) {
    return AiDailyReportState(
      isLoading: isLoading ?? this.isLoading,
      analysis: clearAnalysis ? null : (analysis ?? this.analysis),
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => <Object?>[isLoading, analysis, error];
}
