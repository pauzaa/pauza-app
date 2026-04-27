import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pauza/src/features/ai/addiction_check/model/addiction_check_request_dto.dart';
import 'package:pauza/src/features/ai/addiction_check/model/ai_app_usage_history_dto.dart';
import 'package:pauza/src/features/ai/addiction_check/model/ai_daily_screen_time_dto.dart';
import 'package:pauza/src/features/ai/common/model/ai_app_usage_item_dto.dart';
import 'package:pauza/src/features/ai/daily_report/model/daily_report_request_dto.dart';
import 'package:pauza/src/features/ai/data/ai_repository.dart';
import 'package:pauza/src/features/ai/focus_schedule/model/focus_schedule_request_dto.dart';
import 'package:pauza/src/features/ai/usage_analysis/model/usage_analysis_request_dto.dart';
import 'package:pauza/src/features/stats/usage_stats/model/app_usage_entry.dart';
import 'package:pauza/src/features/stats/usage_stats/model/category_usage_bucket.dart';
import 'package:pauza/src/features/stats/usage_stats/model/device_event_snapshot.dart';
import 'package:pauza/src/features/stats/usage_stats/model/usage_stats_snapshot.dart';
import 'package:pauza/src/features/streaks/common/model/streak_types.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

import '../../../helpers/helpers.dart';

void main() {
  late MockAiRemoteDataSource remoteDataSource;
  late MockStatsUsageRepository usageRepository;
  late MockStreaksRepository streaksRepository;
  late AiRepository repository;

  setUpAll(() {
    registerFallbackValue(DateTime(2026));
    registerFallbackValue(DateTimeRange(start: DateTime(2026), end: DateTime(2026, 1, 2)));
    registerFallbackValue(
      const UsageAnalysisRequestDto(period: 'daily', appUsage: IListConst<AiAppUsageItemDto>(<AiAppUsageItemDto>[])),
    );
    registerFallbackValue(
      const FocusScheduleRequestDto(
        appUsage: IListConst<AiAppUsageItemDto>(<AiAppUsageItemDto>[]),
        preferredFocusHours: 4,
        timezone: 'UTC',
      ),
    );
    registerFallbackValue(
      const DailyReportRequestDto(date: '2026-03-30', appUsage: IListConst<AiAppUsageItemDto>(<AiAppUsageItemDto>[])),
    );
    registerFallbackValue(
      const AddictionCheckRequestDto(
        appUsageHistory: IListConst<AiAppUsageHistoryDto>(<AiAppUsageHistoryDto>[]),
        dailyScreenTimeHistory: IListConst<AiDailyScreenTimeDto>(<AiDailyScreenTimeDto>[]),
      ),
    );
  });

  setUp(() {
    remoteDataSource = MockAiRemoteDataSource();
    usageRepository = MockStatsUsageRepository();
    streaksRepository = MockStreaksRepository();
    repository = AiRepositoryImpl(
      remoteDataSource: remoteDataSource,
      usageRepository: usageRepository,
      streaksRepository: streaksRepository,
      now: () => _now,
      getLocalTimezone: () async => 'Asia/Tashkent',
    );

    when(() => usageRepository.getUsageSnapshot(window: any(named: 'window'))).thenAnswer((_) async => _usageSnapshot);
    when(
      () => usageRepository.getExactDeviceEventSnapshot(window: any(named: 'window')),
    ).thenAnswer((_) async => _oversizedDeviceSnapshot);
    when(
      () => streaksRepository.getGlobalSnapshot(nowLocal: any(named: 'nowLocal')),
    ).thenAnswer((_) async => makeStreakSnapshot(currentStreakDays: const CurrentStreakDays(3)));
    when(() => remoteDataSource.analyzeUsage(any())).thenAnswer((_) async => 'analysis');
    when(() => remoteDataSource.suggestFocusSchedule(any())).thenAnswer((_) async => 'schedule');
    when(() => remoteDataSource.generateDailyReport(any())).thenAnswer((_) async => 'report');
    when(() => remoteDataSource.checkAddiction(any())).thenAnswer((_) async => 'addiction');
  });

  test('normalizes long usage analysis ranges to a weekly request capped to server limits', () async {
    final result = await repository.analyzeUsage(
      window: DateTimeRange(start: DateTime(2026, 3), end: DateTime(2026, 3, 30).dayEnd),
    );

    final expectedWindow = DateTimeRange(start: DateTime(2026, 3, 24), end: DateTime(2026, 3, 30).dayEnd);
    final usageWindow =
        verify(() => usageRepository.getUsageSnapshot(window: captureAny(named: 'window'))).captured.single
            as DateTimeRange;
    final eventWindow =
        verify(() => usageRepository.getExactDeviceEventSnapshot(window: captureAny(named: 'window'))).captured.single
            as DateTimeRange;
    final request =
        verify(() => remoteDataSource.analyzeUsage(captureAny())).captured.single as UsageAnalysisRequestDto;

    expect(result, 'analysis');
    expect(usageWindow, expectedWindow);
    expect(eventWindow, expectedWindow);
    expect(request.period, 'weekly');
    expect(request.totalScreenTimeMs, maxAiWeeklyUsageMs);
    expect(request.totalUnlocks, 42);
    expect(request.appUsage, hasLength(maxAiAppUsageItems));
    expect(request.appUsage.first.totalTimeMs, maxAiWeeklyUsageMs);
    expect(request.appUsage.last.appIdentifier, 'com.example.app499');
  });

  test('suggests a focus schedule from weekly usage and local timezone', () async {
    final result = await repository.suggestFocusSchedule();

    final usageWindow =
        verify(() => usageRepository.getUsageSnapshot(window: captureAny(named: 'window'))).captured.single
            as DateTimeRange;
    final request =
        verify(() => remoteDataSource.suggestFocusSchedule(captureAny())).captured.single as FocusScheduleRequestDto;

    expect(result, 'schedule');
    expect(usageWindow, DateTimeRange(start: DateTime(2026, 3, 24), end: DateTime(2026, 3, 30).dayEnd));
    expect(request.preferredFocusHours, 4);
    expect(request.timezone, 'Asia/Tashkent');
    expect(request.appUsage.first.totalTimeMs, maxAiWeeklyUsageMs);
  });

  test('generates daily report with capped screen time, unlocks, and streak days', () async {
    final result = await repository.generateDailyReport();

    final request =
        verify(() => remoteDataSource.generateDailyReport(captureAny())).captured.single as DailyReportRequestDto;

    expect(result, 'report');
    expect(request.date, '2026-03-30');
    expect(request.totalScreenTimeMs, Duration.millisecondsPerDay);
    expect(request.totalUnlocks, 42);
    expect(request.streakDays, 3);
    expect(request.appUsage.first.totalTimeMs, maxAiDailyUsageMs);
  });

  test('builds a seven-day addiction history with daily screen time capped', () async {
    final result = await repository.checkAddiction();

    final request =
        verify(() => remoteDataSource.checkAddiction(captureAny())).captured.single as AddictionCheckRequestDto;

    expect(result, 'addiction');
    expect(request.appUsageHistory, hasLength(7));
    expect(request.dailyScreenTimeHistory, hasLength(7));
    expect(request.appUsageHistory.first.date, '2026-03-30');
    expect(request.dailyScreenTimeHistory.first.date, '2026-03-30');
    expect(
      request.dailyScreenTimeHistory.map((item) => item.totalScreenTimeMs),
      everyElement(Duration.millisecondsPerDay),
    );
  });
}

final _now = DateTime(2026, 3, 30, 12);

final _usageSnapshot = UsageStatsSnapshot(
  totalScreenTime: const Duration(days: 8),
  totalLaunchCount: 4,
  appUsageEntries: List<AppUsageEntry>.generate(
    maxAiAppUsageItems + 1,
    (index) => AppUsageEntry(
      appInfo: AndroidAppInfo(
        packageId: AppIdentifier.android('com.example.app$index'),
        name: 'App $index',
        category: 'Productivity',
      ),
      totalDuration: Duration(milliseconds: maxAiWeeklyUsageMs + index + 1),
      launchCount: index,
      shareOfTotal: 0,
    ),
  ).toIList(),
  categoryBreakdown: const IListConst<CategoryUsageBucket>(<CategoryUsageBucket>[]),
  averageDailyScreenTime: const Duration(hours: 2),
);

const _oversizedDeviceSnapshot = DeviceEventSnapshot(
  screenOnCount: 1,
  totalScreenOnTime: Duration(days: 8),
  unlockCount: 42,
  eventEntries: IListConst<DeviceEventStats>(<DeviceEventStats>[]),
);
