import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:pauza/src/core/common/model/local_day_key.dart';
import 'package:pauza/src/features/stats/usage_stats/data/stats_usage_repository.dart';
import 'package:pauza/src/features/stats/usage_stats/model/app_usage_detail.dart';
import 'package:pauza/src/features/stats/usage_stats/model/app_usage_entry.dart';
import 'package:pauza/src/features/stats/usage_stats/model/category_usage_bucket.dart';
import 'package:pauza/src/features/stats/usage_stats/model/daily_usage_point.dart';
import 'package:pauza/src/features/stats/usage_stats/model/device_event_snapshot.dart';
import 'package:pauza/src/features/stats/usage_stats/model/usage_stats_snapshot.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

final class MockStatsUsageRepository implements StatsUsageRepository {
  const MockStatsUsageRepository();

  @override
  Future<UsageStatsSnapshot> getUsageSnapshot({required DateTimeRange window}) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    return UsageStatsSnapshot(
      totalScreenTime: const Duration(hours: 4, minutes: 30),
      totalLaunchCount: 150,
      appUsageEntries: _appEntries,
      categoryBreakdown: _categoryBreakdown,
      averageDailyScreenTime: const Duration(hours: 4, minutes: 30),
    );
  }

  @override
  Future<IList<DailyUsagePoint>> getDailyUsageTrend({required DateTimeRange window}) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    return const <DailyUsagePoint>[
      DailyUsagePoint(
        localDay: LocalDayKey('2026-03-16'),
        totalScreenTime: Duration(hours: 5, minutes: 12),
        totalLaunchCount: 180,
      ),
      DailyUsagePoint(
        localDay: LocalDayKey('2026-03-17'),
        totalScreenTime: Duration(hours: 3, minutes: 45),
        totalLaunchCount: 120,
      ),
      DailyUsagePoint(
        localDay: LocalDayKey('2026-03-18'),
        totalScreenTime: Duration(hours: 4, minutes: 58),
        totalLaunchCount: 165,
      ),
      DailyUsagePoint(
        localDay: LocalDayKey('2026-03-19'),
        totalScreenTime: Duration(hours: 3, minutes: 20),
        totalLaunchCount: 110,
      ),
      DailyUsagePoint(
        localDay: LocalDayKey('2026-03-20'),
        totalScreenTime: Duration(hours: 5, minutes: 35),
        totalLaunchCount: 195,
      ),
      DailyUsagePoint(
        localDay: LocalDayKey('2026-03-21'),
        totalScreenTime: Duration(hours: 4, minutes: 10),
        totalLaunchCount: 140,
      ),
      DailyUsagePoint(
        localDay: LocalDayKey('2026-03-22'),
        totalScreenTime: Duration(hours: 4, minutes: 30),
        totalLaunchCount: 150,
      ),
    ].toIList();
  }

  @override
  Future<AppUsageDetail> getAppDetail({
    required AndroidAppInfo appInfo,
    required String packageId,
    required DateTimeRange window,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    return AppUsageDetail(
      appInfo: appInfo,
      totalDuration: const Duration(hours: 1, minutes: 5),
      launchCount: 32,
      lastTimeUsed: DateTime(2026, 3, 22, 14, 30),
      dailyTrend: const <DailyUsagePoint>[
        DailyUsagePoint(
          localDay: LocalDayKey('2026-03-16'),
          totalScreenTime: Duration(minutes: 18),
          totalLaunchCount: 6,
        ),
        DailyUsagePoint(
          localDay: LocalDayKey('2026-03-17'),
          totalScreenTime: Duration(minutes: 12),
          totalLaunchCount: 4,
        ),
        DailyUsagePoint(
          localDay: LocalDayKey('2026-03-18'),
          totalScreenTime: Duration(minutes: 22),
          totalLaunchCount: 7,
        ),
        DailyUsagePoint(
          localDay: LocalDayKey('2026-03-19'),
          totalScreenTime: Duration(minutes: 8),
          totalLaunchCount: 3,
        ),
        DailyUsagePoint(
          localDay: LocalDayKey('2026-03-20'),
          totalScreenTime: Duration(minutes: 15),
          totalLaunchCount: 5,
        ),
        DailyUsagePoint(
          localDay: LocalDayKey('2026-03-21'),
          totalScreenTime: Duration(minutes: 10),
          totalLaunchCount: 4,
        ),
        DailyUsagePoint(
          localDay: LocalDayKey('2026-03-22'),
          totalScreenTime: Duration(minutes: 14),
          totalLaunchCount: 5,
        ),
      ].toIList(),
      isInactive: false,
    );
  }

  @override
  Future<DeviceEventSnapshot> getDeviceEventSnapshot({
    required DateTimeRange window,
    UsageStatsInterval intervalType = UsageStatsInterval.daily,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    return const DeviceEventSnapshot(
      screenOnCount: 45,
      totalScreenOnTime: Duration(hours: 4, minutes: 30),
      unlockCount: 32,
      eventEntries: IListConst(<DeviceEventStats>[]),
    );
  }

  @override
  Future<DeviceEventSnapshot> getExactDeviceEventSnapshot({required DateTimeRange window}) =>
      getDeviceEventSnapshot(window: window);
}

// ---------------------------------------------------------------------------
// Static mock data
// ---------------------------------------------------------------------------

const _totalMs = 16200000; // 4h 30m in ms

final _appEntries = const <AppUsageEntry>[
  AppUsageEntry(
    appInfo: AndroidAppInfo(
      packageId: AppIdentifier.android('com.instagram.android'),
      name: 'Instagram',
      category: 'Social',
    ),
    totalDuration: Duration(hours: 1, minutes: 5),
    launchCount: 32,
    shareOfTotal: 3900000 / _totalMs,
  ),
  AppUsageEntry(
    appInfo: AndroidAppInfo(
      packageId: AppIdentifier.android('com.zhiliaoapp.musically'),
      name: 'TikTok',
      category: 'Social',
    ),
    totalDuration: Duration(minutes: 52),
    launchCount: 18,
    shareOfTotal: 3120000 / _totalMs,
  ),
  AppUsageEntry(
    appInfo: AndroidAppInfo(
      packageId: AppIdentifier.android('com.google.android.youtube'),
      name: 'YouTube',
      category: 'Video',
    ),
    totalDuration: Duration(minutes: 45),
    launchCount: 12,
    shareOfTotal: 2700000 / _totalMs,
  ),
  AppUsageEntry(
    appInfo: AndroidAppInfo(
      packageId: AppIdentifier.android('org.telegram.messenger'),
      name: 'Telegram',
      category: 'Communication',
    ),
    totalDuration: Duration(minutes: 38),
    launchCount: 28,
    shareOfTotal: 2280000 / _totalMs,
  ),
  AppUsageEntry(
    appInfo: AndroidAppInfo(
      packageId: AppIdentifier.android('com.whatsapp'),
      name: 'WhatsApp',
      category: 'Communication',
    ),
    totalDuration: Duration(minutes: 22),
    launchCount: 20,
    shareOfTotal: 1320000 / _totalMs,
  ),
  AppUsageEntry(
    appInfo: AndroidAppInfo(packageId: AppIdentifier.android('com.twitter.android'), name: 'X', category: 'Social'),
    totalDuration: Duration(minutes: 18),
    launchCount: 14,
    shareOfTotal: 1080000 / _totalMs,
  ),
  AppUsageEntry(
    appInfo: AndroidAppInfo(packageId: AppIdentifier.android('com.spotify.music'), name: 'Spotify', category: 'Music'),
    totalDuration: Duration(minutes: 15),
    launchCount: 8,
    shareOfTotal: 900000 / _totalMs,
  ),
  AppUsageEntry(
    appInfo: AndroidAppInfo(
      packageId: AppIdentifier.android('com.google.android.gm'),
      name: 'Gmail',
      category: 'Productivity',
    ),
    totalDuration: Duration(minutes: 12),
    launchCount: 10,
    shareOfTotal: 720000 / _totalMs,
  ),
  AppUsageEntry(
    appInfo: AndroidAppInfo(
      packageId: AppIdentifier.android('com.google.android.apps.maps'),
      name: 'Maps',
      category: 'Navigation',
    ),
    totalDuration: Duration(minutes: 8),
    launchCount: 4,
    shareOfTotal: 480000 / _totalMs,
  ),
  AppUsageEntry(
    appInfo: AndroidAppInfo(
      packageId: AppIdentifier.android('com.google.android.apps.photos'),
      name: 'Photos',
      category: 'Photography',
    ),
    totalDuration: Duration(minutes: 5),
    launchCount: 4,
    shareOfTotal: 300000 / _totalMs,
  ),
].toIList();

final _categoryBreakdown = const <CategoryUsageBucket>[
  CategoryUsageBucket(
    category: 'Social',
    totalDuration: Duration(hours: 1, minutes: 55),
    appCount: 3,
    shareOfTotal: 0.43,
  ),
  CategoryUsageBucket(category: 'Communication', totalDuration: Duration(hours: 1), appCount: 2, shareOfTotal: 0.22),
  CategoryUsageBucket(category: 'Video', totalDuration: Duration(minutes: 45), appCount: 1, shareOfTotal: 0.17),
  CategoryUsageBucket(category: 'Music', totalDuration: Duration(minutes: 15), appCount: 1, shareOfTotal: 0.06),
  CategoryUsageBucket(category: 'Productivity', totalDuration: Duration(minutes: 12), appCount: 1, shareOfTotal: 0.04),
  CategoryUsageBucket(category: 'Navigation', totalDuration: Duration(minutes: 8), appCount: 1, shareOfTotal: 0.03),
  CategoryUsageBucket(category: 'Photography', totalDuration: Duration(minutes: 5), appCount: 1, shareOfTotal: 0.02),
].toIList();
