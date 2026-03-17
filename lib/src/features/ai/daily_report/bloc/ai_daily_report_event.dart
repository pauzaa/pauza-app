part of 'ai_daily_report_bloc.dart';

sealed class AiDailyReportEvent {
  const AiDailyReportEvent();
}

final class AiDailyReportRequested extends AiDailyReportEvent {
  const AiDailyReportRequested();
}
