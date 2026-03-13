import 'package:pauza/src/core/api_client/api_client.dart';
import 'package:pauza/src/features/ai/addiction_check/model/addiction_check_request_dto.dart';
import 'package:pauza/src/features/ai/common/model/ai_error.dart';
import 'package:pauza/src/features/ai/daily_report/model/daily_report_request_dto.dart';
import 'package:pauza/src/features/ai/focus_schedule/model/focus_schedule_request_dto.dart';
import 'package:pauza/src/features/ai/usage_analysis/model/usage_analysis_request_dto.dart';

abstract interface class AiRemoteDataSource {
  Future<String> analyzeUsage(UsageAnalysisRequestDto request);
  Future<String> suggestFocusSchedule(FocusScheduleRequestDto request);
  Future<String> generateDailyReport(DailyReportRequestDto request);
  Future<String> checkAddiction(AddictionCheckRequestDto request);
}

final class AiRemoteDataSourceImpl implements AiRemoteDataSource {
  const AiRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<String> analyzeUsage(UsageAnalysisRequestDto request) async =>
      _post('/api/v1/ai/usage-analysis', request.toJson());

  @override
  Future<String> suggestFocusSchedule(
    FocusScheduleRequestDto request,
  ) async =>
      _post('/api/v1/ai/focus-schedule', request.toJson());

  @override
  Future<String> generateDailyReport(DailyReportRequestDto request) async =>
      _post('/api/v1/ai/daily-report', request.toJson());

  @override
  Future<String> checkAddiction(AddictionCheckRequestDto request) async =>
      _post('/api/v1/ai/addiction-check', request.toJson());

  Future<String> _post(String path, Map<String, Object?> body) async {
    try {
      final response = await _apiClient.post(path, body: body);
      return response.data!['analysis'] as String;
    } on ApiClientException catch (e) {
      throw AiError.fromApiException(e);
    }
  }
}
