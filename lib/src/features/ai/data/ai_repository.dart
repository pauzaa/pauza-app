import 'package:pauza/src/features/ai/addiction_check/model/addiction_check_request_dto.dart';
import 'package:pauza/src/features/ai/common/model/ai_error.dart';
import 'package:pauza/src/features/ai/daily_report/model/daily_report_request_dto.dart';
import 'package:pauza/src/features/ai/data/ai_remote_data_source.dart';
import 'package:pauza/src/features/ai/focus_schedule/model/focus_schedule_request_dto.dart';
import 'package:pauza/src/features/ai/usage_analysis/model/usage_analysis_request_dto.dart';

abstract interface class AiRepository {
  Future<String> analyzeUsage(UsageAnalysisRequestDto request);
  Future<String> suggestFocusSchedule(FocusScheduleRequestDto request);
  Future<String> generateDailyReport(DailyReportRequestDto request);
  Future<String> checkAddiction(AddictionCheckRequestDto request);
}

final class AiRepositoryImpl implements AiRepository {
  const AiRepositoryImpl({required AiRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final AiRemoteDataSource _remoteDataSource;

  @override
  Future<String> analyzeUsage(UsageAnalysisRequestDto request) async {
    try {
      return await _remoteDataSource.analyzeUsage(request);
    } on AiError {
      rethrow;
    } on Object catch (e) {
      throw AiUnknownError(e);
    }
  }

  @override
  Future<String> suggestFocusSchedule(
    FocusScheduleRequestDto request,
  ) async {
    try {
      return await _remoteDataSource.suggestFocusSchedule(request);
    } on AiError {
      rethrow;
    } on Object catch (e) {
      throw AiUnknownError(e);
    }
  }

  @override
  Future<String> generateDailyReport(DailyReportRequestDto request) async {
    try {
      return await _remoteDataSource.generateDailyReport(request);
    } on AiError {
      rethrow;
    } on Object catch (e) {
      throw AiUnknownError(e);
    }
  }

  @override
  Future<String> checkAddiction(AddictionCheckRequestDto request) async {
    try {
      return await _remoteDataSource.checkAddiction(request);
    } on AiError {
      rethrow;
    } on Object catch (e) {
      throw AiUnknownError(e);
    }
  }
}
