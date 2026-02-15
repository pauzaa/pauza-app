import 'package:pauza_screen_time/pauza_screen_time.dart';

abstract interface class StatsUsageRepository {
  Future<List<UsageStats>> getUsageStats({
    required DateTime start,
    required DateTime end,
  });
}

class StatsUsageRepositoryImpl implements StatsUsageRepository {
  StatsUsageRepositoryImpl({
    required UsageStatsManager usageStatsManager,
    required InstalledAppsManager installedAppsManager,
  }) : _usageStatsManager = usageStatsManager,
       _installedAppsManager = installedAppsManager;

  final UsageStatsManager _usageStatsManager;
  final InstalledAppsManager _installedAppsManager;

  Map<AppIdentifier, AndroidAppInfo>? _cachedAndroidApps;

  @override
  Future<List<UsageStats>> getUsageStats({
    required DateTime start,
    required DateTime end,
  }) async {
    final usage = await _usageStatsManager.getUsageStats(
      startDate: start,
      endDate: end,
    );

    final apps = await _getAndroidAppsById();
    return usage
        .map((entry) {
          if (entry.appInfo.category != null) {
            return entry;
          }
          final appInfo = apps[entry.appInfo.packageId];
          if (appInfo == null) {
            return entry;
          }
          return UsageStats(
            appInfo: AndroidAppInfo(
              packageId: entry.appInfo.packageId,
              name: entry.appInfo.name,
              icon: entry.appInfo.icon,
              category: appInfo.category,
              isSystemApp: entry.appInfo.isSystemApp,
            ),
            totalDuration: entry.totalDuration,
            totalLaunchCount: entry.totalLaunchCount,
            bucketStart: entry.bucketStart,
            bucketEnd: entry.bucketEnd,
            lastTimeUsed: entry.lastTimeUsed,
            lastTimeVisible: entry.lastTimeVisible,
          );
        })
        .toList(growable: false);
  }

  Future<Map<AppIdentifier, AndroidAppInfo>> _getAndroidAppsById() async {
    if (_cachedAndroidApps != null) {
      return _cachedAndroidApps!;
    }
    final apps = await _installedAppsManager.getAndroidInstalledApps(
      includeSystemApps: true,
      includeIcons: false,
    );
    final map = <AppIdentifier, AndroidAppInfo>{
      for (final app in apps) app.packageId: app,
    };
    _cachedAndroidApps = map;
    return map;
  }
}
