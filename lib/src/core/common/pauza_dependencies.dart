import 'package:appfuse/appfuse.dart';
import 'package:flutter/widgets.dart';
import 'package:pauza/src/core/local_database/local_database.dart';
import 'package:pauza/src/features/auth/bloc/auth_bloc.dart';
import 'package:pauza/src/features/auth/data/auth_repository.dart';
import 'package:pauza/src/features/auth/data/auth_session_storage.dart';
import 'package:pauza/src/features/auth/domain/auth_gate.dart';
import 'package:pauza/src/features/nfc/data/nfc_manager_client.dart';
import 'package:pauza/src/features/nfc/data/nfc_repository.dart';
import 'package:pauza/src/features/restriction_lifecycle/data/restriction_lifecycle_plugin_client.dart';
import 'package:pauza/src/features/restriction_lifecycle/data/restriction_lifecycle_repository.dart';
import 'package:pauza/src/features/permissions/domain/permission_gate.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart'
    show
        AppRestrictionManager,
        InstalledAppsManager,
        PermissionManager,
        UsageStatsManager;

class PauzaDependencies with AppFuseInitialization {
  late final LocalDatabase localDatabase;
  late final PauzaPermissionGate permissionGate;
  late final PermissionManager permissionManager;
  late final InstalledAppsManager installedAppsManager;
  late final AppRestrictionManager appRestrictionManager;
  late final UsageStatsManager usageStatsManager;
  late final RestrictionLifecycleRepository restrictionLifecycleRepository;
  late final NfcRepository nfcRepository;
  late final AuthSessionStorage authSessionStorage;
  late final AuthRepository authRepository;
  late final PauzaAuthGate authGate;
  late final AuthBloc authBloc;

  static PauzaDependencies of(BuildContext context) =>
      AppFuseScope.of(context).init as PauzaDependencies;

  @override
  Map<String, InitializationStep> get steps => <String, InitializationStep>{
    'init local database': (_) async {
      localDatabase = SqfliteLocalDatabase(
        schema: const PauzaLocalDatabaseSchemaV1(),
      );
      await localDatabase.open();
    },
    'init permissions': (_) async {
      permissionManager = PermissionManager();
      permissionGate = PauzaPermissionGateNotifier(
        permissionManager: permissionManager,
      );
      await permissionGate.refresh(force: true);
    },
    'init auth': (_) async {
      authSessionStorage = SecureAuthSessionStorage();
      authRepository = AuthRepositoryImpl(sessionStorage: authSessionStorage);
      authGate = PauzaAuthGateNotifier(authRepository: authRepository);
      authBloc = AuthBloc(authRepository: authRepository)..add(const AuthStarted());
    },
    'init managers': (_) async {
      installedAppsManager = InstalledAppsManager();
      appRestrictionManager = AppRestrictionManager();
      usageStatsManager = UsageStatsManager();
      nfcRepository = NfcRepositoryImpl(managerClient: NfcManagerClient());
    },
    'init restriction lifecycle sync coordinator': (_) async {
      restrictionLifecycleRepository = RestrictionLifecycleRepositoryImpl(
        localDatabase: localDatabase,
        pluginClient: RestrictionLifecyclePluginClientImpl(
          restrictions: appRestrictionManager,
        ),
      );
      try {
        await restrictionLifecycleRepository.syncFromPluginQueue();
      } on Object {
        // Ignore startup sync failures. Next resume/manual flow retries ingestion.
      }
    },
  };
}
