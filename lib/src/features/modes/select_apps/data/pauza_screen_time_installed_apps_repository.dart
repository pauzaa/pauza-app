import 'package:pauza_screen_time/pauza_screen_time.dart';

abstract interface class InstalledAppsRepository {
  Future<List<AndroidAppInfo>> getAndroidInstalledApps({
    bool includeSystemApps = false,
    bool includeIcons = true,
  });

  Future<List<IOSAppInfo>> selectIOSApps({List<IOSAppInfo>? preSelectedApps});
}

class PauzaScreenTimeInstalledAppsRepository implements InstalledAppsRepository {
  PauzaScreenTimeInstalledAppsRepository({required InstalledAppsManager installedAppsManager})
    : _installedAppsManager = installedAppsManager;

  final InstalledAppsManager _installedAppsManager;

  @override
  Future<List<AndroidAppInfo>> getAndroidInstalledApps({
    bool includeSystemApps = false,
    bool includeIcons = true,
  }) => _installedAppsManager.getAndroidInstalledApps(
    includeSystemApps: includeSystemApps,
    includeIcons: includeIcons,
  );

  @override
  Future<List<IOSAppInfo>> selectIOSApps({List<IOSAppInfo>? preSelectedApps}) =>
      _installedAppsManager.selectIOSApps(preSelectedApps: preSelectedApps);
}
