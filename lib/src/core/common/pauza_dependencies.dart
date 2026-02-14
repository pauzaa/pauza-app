import 'package:appfuse/appfuse.dart';
import 'package:flutter/widgets.dart';
import 'package:pauza/src/core/local_database/local_database.dart';
import 'package:pauza/src/features/permissions/domain/permission_gate.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart'
    show PermissionManager, AppRestrictionManager, InstalledAppsManager;

class PauzaDependencies with AppFuseInitialization {
  late final LocalDatabase localDatabase;
  late final PauzaPermissionGate permissionGate;
  late final PermissionManager permissionManager;
  late final InstalledAppsManager installedAppsManager;
  late final AppRestrictionManager appRestrictionManager;

  static PauzaDependencies of(BuildContext context) =>
      AppFuseScope.of(context).init as PauzaDependencies;

  @override
  Map<String, InitializationStep> get steps => <String, InitializationStep>{
    'init local database': (_) async {
      localDatabase = SqfliteLocalDatabase(schema: const PauzaLocalDatabaseSchemaV1());
      await localDatabase.open();
    },
    'init permissions': (_) async {
      permissionManager = PermissionManager();
      permissionGate = PauzaPermissionGateNotifier(permissionManager: permissionManager);
      await permissionGate.refresh(force: true);
    },
    'init managers': (_) async {
      installedAppsManager = InstalledAppsManager();
      appRestrictionManager = AppRestrictionManager();
    },
  };
}
