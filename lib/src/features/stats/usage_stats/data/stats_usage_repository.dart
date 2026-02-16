import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

abstract interface class StatsUsageRepository {
  Future<IList<UsageStats>> getUsageStats({required DateTime start, required DateTime end});
}

class StatsUsageRepositoryImpl implements StatsUsageRepository {
  StatsUsageRepositoryImpl({
    required UsageStatsManager usageStatsManager,
    required InstalledAppsManager installedAppsManager,
  }) : _usageStatsManager = usageStatsManager;
  //  _installedAppsManager = installedAppsManager;

  final UsageStatsManager _usageStatsManager;
  // final InstalledAppsManager _installedAppsManager;

  // Map<AppIdentifier, AndroidAppInfo>? _cachedAndroidApps;

  @override
  Future<IList<UsageStats>> getUsageStats({required DateTime start, required DateTime end}) async {
    final usage = await _usageStatsManager.getUsageStats(startDate: start, endDate: end);

    // final apps = await _getAndroidAppsById();
    return usage.lock;
  }

  // Future<Map<AppIdentifier, AndroidAppInfo>> _getAndroidAppsById() async {
  //   if (_cachedAndroidApps != null) {
  //     return _cachedAndroidApps!;
  //   }
  //   final apps = await _installedAppsManager.getAndroidInstalledApps(
  //     includeSystemApps: true,
  //     includeIcons: false,
  //   );
  //   final map = <AppIdentifier, AndroidAppInfo>{for (final app in apps) app.packageId: app};
  //   _cachedAndroidApps = map;
  //   return map;
  // }
}
