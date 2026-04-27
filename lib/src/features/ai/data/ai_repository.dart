import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

import 'package:pauza/src/core/api_client/api_client.dart';
import 'package:pauza/src/core/common/local_day_extensions.dart';
import 'package:pauza/src/features/ai/addiction_check/model/addiction_check_request_dto.dart';
import 'package:pauza/src/features/ai/addiction_check/model/ai_app_usage_history_dto.dart';
import 'package:pauza/src/features/ai/addiction_check/model/ai_daily_screen_time_dto.dart';
import 'package:pauza/src/features/ai/common/model/ai_app_usage_item_dto.dart';
import 'package:pauza/src/features/ai/daily_report/model/daily_report_request_dto.dart';
import 'package:pauza/src/features/ai/data/ai_remote_data_source.dart';
import 'package:pauza/src/features/ai/focus_schedule/model/focus_schedule_request_dto.dart';
import 'package:pauza/src/features/ai/usage_analysis/model/usage_analysis_request_dto.dart';
import 'package:pauza/src/features/stats/usage_stats/data/stats_usage_repository.dart';
import 'package:pauza/src/features/streaks/data/streaks_repository.dart';

abstract interface class AiRepository {
  Future<String> analyzeUsage({required DateTimeRange window});
  Future<String> suggestFocusSchedule();
  Future<String> generateDailyReport();
  Future<String> checkAddiction();
}

final class AiRepositoryImpl implements AiRepository {
  AiRepositoryImpl({
    required AiRemoteDataSource remoteDataSource,
    required StatsUsageRepository usageRepository,
    required StreaksRepository streaksRepository,
    DateTime Function()? now,
    Future<String> Function()? getLocalTimezone,
  }) : _remoteDataSource = remoteDataSource,
       _usageRepository = usageRepository,
       _streaksRepository = streaksRepository,
       _now = now ?? DateTime.now,
       _getLocalTimezone = getLocalTimezone ?? _defaultGetLocalTimezone;

  final AiRemoteDataSource _remoteDataSource;
  final StatsUsageRepository _usageRepository;
  final StreaksRepository _streaksRepository;
  final DateTime Function() _now;
  final Future<String> Function() _getLocalTimezone;

  @override
  Future<String> analyzeUsage({required DateTimeRange window}) async {
    return _guardApiErrors(() async {
      final selection = _normalizeUsageAnalysisWindow(window);
      final snapshotFuture = _usageRepository.getUsageSnapshot(window: selection.window);
      final deviceEventFuture = _usageRepository.getExactDeviceEventSnapshot(window: selection.window);

      final snapshot = await snapshotFuture;

      var screenOnTimeMs = snapshot.totalScreenTime.inMilliseconds;
      int? unlockCount;
      try {
        final deviceEvents = await deviceEventFuture;
        screenOnTimeMs = deviceEvents.totalScreenOnTime.inMilliseconds;
        unlockCount = deviceEvents.unlockCount;
      } on Object {
        // Device events are not available on all platforms; fall back to sum-of-apps.
      }

      final request = UsageAnalysisRequestDto(
        period: selection.period,
        appUsage: AiAppUsageItemDto.fromUsageEntries(snapshot.appUsageEntries, maxTotalTimeMs: selection.maxUsageMs),
        totalScreenTimeMs: _capUsageMs(screenOnTimeMs, selection.maxUsageMs),
        totalUnlocks: unlockCount,
      );

      if (request.appUsage.isEmpty) throw const ApiValidationError();
      return await _remoteDataSource.analyzeUsage(request);
    });
  }

  @override
  Future<String> suggestFocusSchedule() async {
    return _guardApiErrors(() async {
      final now = _now();
      final window = DateTimeRange(start: now.dayStart.subtract(const Duration(days: 6)), end: now.dayEnd);
      final snapshot = await _usageRepository.getUsageSnapshot(window: window);

      final request = FocusScheduleRequestDto(
        appUsage: AiAppUsageItemDto.fromUsageEntries(snapshot.appUsageEntries, maxTotalTimeMs: maxAiWeeklyUsageMs),
        preferredFocusHours: _defaultPreferredFocusHours,
        timezone: await _getLocalTimezone(),
      );

      if (request.appUsage.isEmpty) throw const ApiValidationError();
      return await _remoteDataSource.suggestFocusSchedule(request);
    });
  }

  @override
  Future<String> generateDailyReport() async {
    return _guardApiErrors(() async {
      final now = _now();
      final window = DateTimeRange(start: now.dayStart, end: now.dayEnd);

      final (snapshot, streakSnapshot) = await (
        _usageRepository.getUsageSnapshot(window: window),
        _streaksRepository.getGlobalSnapshot(nowLocal: now),
      ).wait;

      var screenOnTimeMs = snapshot.totalScreenTime.inMilliseconds;
      var unlockCount = 0;
      try {
        final deviceEvents = await _usageRepository.getExactDeviceEventSnapshot(window: window);
        screenOnTimeMs = deviceEvents.totalScreenOnTime.inMilliseconds;
        unlockCount = deviceEvents.unlockCount;
      } on Object {
        // Device events are not available on all platforms; fall back to sum-of-apps.
      }

      final request = DailyReportRequestDto(
        date: now.localDayKey,
        appUsage: AiAppUsageItemDto.fromUsageEntries(snapshot.appUsageEntries, maxTotalTimeMs: maxAiDailyUsageMs),
        totalScreenTimeMs: _capDailyScreenTimeMs(screenOnTimeMs),
        totalUnlocks: unlockCount > 0 ? unlockCount : null,
        streakDays: streakSnapshot.currentStreakDays.value > 0 ? streakSnapshot.currentStreakDays.value : null,
      );

      if (request.appUsage.isEmpty) throw const ApiValidationError();
      return await _remoteDataSource.generateDailyReport(request);
    });
  }

  @override
  Future<String> checkAddiction() async {
    return _guardApiErrors(() async {
      final now = _now();
      final days = List<DateTime>.generate(7, (i) => now.subtract(Duration(days: i)));

      final results = await Future.wait(days.map(_fetchAddictionDayData));

      final request = AddictionCheckRequestDto(
        appUsageHistory: results.map((r) => r.$1).toIList(),
        dailyScreenTimeHistory: results.map((r) => r.$2).toIList(),
      );

      if (request.appUsageHistory.isEmpty || request.dailyScreenTimeHistory.isEmpty) {
        throw const ApiValidationError();
      }
      return await _remoteDataSource.checkAddiction(request);
    });
  }

  Future<(AiAppUsageHistoryDto, AiDailyScreenTimeDto)> _fetchAddictionDayData(DateTime day) async {
    final window = DateTimeRange(start: day.dayStart, end: day.dayEnd);
    final snapshot = await _usageRepository.getUsageSnapshot(window: window);

    var screenOnTimeMs = 0;
    var unlockCount = 0;
    try {
      final deviceEvents = await _usageRepository.getExactDeviceEventSnapshot(window: window);
      screenOnTimeMs = deviceEvents.totalScreenOnTime.inMilliseconds;
      unlockCount = deviceEvents.unlockCount;
    } on Object {
      // Device events are not available on all platforms; fall back to sum-of-apps.
      screenOnTimeMs = snapshot.totalScreenTime.inMilliseconds;
    }

    return (
      AiAppUsageHistoryDto(
        date: day.localDayKey,
        apps: AiAppUsageItemDto.fromUsageEntries(snapshot.appUsageEntries, maxTotalTimeMs: maxAiDailyUsageMs),
      ),
      AiDailyScreenTimeDto(
        date: day.localDayKey,
        totalScreenTimeMs: _capDailyScreenTimeMs(screenOnTimeMs),
        totalUnlocks: unlockCount,
      ),
    );
  }

  Future<String> _guardApiErrors(Future<String> Function() action) async {
    try {
      return await action();
    } on ApiError {
      rethrow;
    } on Object catch (e) {
      throw ApiUnknownError(e);
    }
  }
}

const _usageAnalysisWeeklyDays = 7;
const _defaultPreferredFocusHours = 4;
const _maxDailyScreenTimeMs = Duration.millisecondsPerDay;

Future<String> _defaultGetLocalTimezone() async => (await FlutterTimezone.getLocalTimezone()).identifier;

({DateTimeRange window, String period, int maxUsageMs}) _normalizeUsageAnalysisWindow(DateTimeRange selectedWindow) {
  final selectedDays = _dayCount(selectedWindow);
  if (selectedDays <= 1) {
    return (
      window: DateTimeRange(start: selectedWindow.start.dayStart, end: selectedWindow.start.dayEnd),
      period: 'daily',
      maxUsageMs: maxAiDailyUsageMs,
    );
  }

  final endDay = selectedWindow.end.dayStart;
  return (
    window: DateTimeRange(
      start: endDay.subtract(const Duration(days: _usageAnalysisWeeklyDays - 1)),
      end: endDay.dayEnd,
    ),
    period: 'weekly',
    maxUsageMs: maxAiWeeklyUsageMs,
  );
}

int _dayCount(DateTimeRange window) => window.end.dayStart.difference(window.start.dayStart).inDays + 1;

int _capUsageMs(int value, int maxUsageMs) => value.clamp(0, maxUsageMs).toInt();

int _capDailyScreenTimeMs(int value) => value.clamp(0, _maxDailyScreenTimeMs).toInt();
