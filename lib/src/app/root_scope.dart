import 'package:flutter/material.dart';
import 'package:pauza/src/core/init/pauza_dependencies.dart';
import 'package:pauza/src/core/common/pauza_platform.dart';
import 'package:pauza/src/features/auth/bloc/auth_bloc.dart';
import 'package:pauza/src/features/home/data/pauza_blocking_repository.dart';
import 'package:pauza/src/features/modes/select_apps/data/pauza_screen_time_installed_apps_repository.dart';
import 'package:pauza/src/features/modes/common/data/modes_repository.dart';
import 'package:pauza/src/features/nfc/data/nfc_repository.dart';
import 'package:pauza/src/features/nfc_chip_config/data/nfc_linked_chips_repository.dart';
import 'package:pauza/src/features/profile/common/bloc/current_user_bloc.dart';
import 'package:pauza/src/features/qr_code_config/data/qr_linked_codes_repository.dart';
import 'package:pauza/src/features/restriction_lifecycle/sync/restriction_lifecycle_sync_coordinator.dart';
import 'package:pauza/src/features/streaks/data/streaks_repository.dart';
import 'package:pauza/src/features/stats/usage_stats/data/stats_usage_repository.dart';

class RootScope extends StatefulWidget {
  const RootScope({required this.child, this.dependencies, super.key});

  final Widget child;
  final PauzaDependencies? dependencies;

  @override
  State<RootScope> createState() => RootScopeState();

  static RootScopeState of(BuildContext context, {bool listen = false}) =>
      _InheritedRootScope.of(context, listen: listen).data;
}

class RootScopeState extends State<RootScope> {
  late final BlockingRepository blockingRepository;
  late final ModesRepository modesRepository;
  late final InstalledAppsRepository installedAppsRepository;
  late final NfcRepository nfcRepository;
  late final bool hasNfcSupport;
  late final NfcLinkedChipsRepository nfcLinkedChipsRepository;
  late final QrLinkedCodesRepository qrLinkedCodesRepository;
  late final StatsUsageRepository statsUsageRepository;
  late final CurrentUserBloc currentUserBloc;
  late final AuthBloc authBloc;
  late final RestrictionLifecycleSyncCoordinator restrictionLifecycleSyncCoordinator;
  late final StreaksRepository streaksRepository;

  @override
  void initState() {
    final dependencies = widget.dependencies ?? PauzaDependencies.of(context);

    blockingRepository = PauzaBlockingRepository(
      restrictions: dependencies.appRestrictionManager,
      restrictionLifecycleRepository: dependencies.restrictionLifecycleRepository,
    );

    modesRepository = ModesRepositoryImpl(
      localDatabase: dependencies.localDatabase,
      platform: kPauzaPlatform,
      restrictions: dependencies.appRestrictionManager,
    );

    installedAppsRepository = PauzaScreenTimeInstalledAppsRepository(
      installedAppsManager: dependencies.installedAppsManager,
    );
    statsUsageRepository = StatsUsageRepositoryImpl(
      usageStatsManager: dependencies.usageStatsManager,
      installedAppsManager: dependencies.installedAppsManager,
    );

    nfcRepository = dependencies.nfcRepository;
    hasNfcSupport = dependencies.hasNfcSupport;
    nfcLinkedChipsRepository = NfcLinkedChipsRepositoryImpl(localDatabase: dependencies.localDatabase);
    qrLinkedCodesRepository = QrLinkedCodesRepositoryImpl(localDatabase: dependencies.localDatabase);
    // UI-level session/profile composition lives in RootScope (runtime scope),
    // not in infra dependencies.
    currentUserBloc = CurrentUserBloc(
      authRepository: dependencies.authRepository,
      userProfileRepository: dependencies.userProfileRepository,
      ttl: const Duration(minutes: 15),
      nowUtc: () => DateTime.now().toUtc(),
    );

    authBloc = AuthBloc(authRepository: dependencies.authRepository);

    restrictionLifecycleSyncCoordinator = RestrictionLifecycleSyncCoordinator(
      repository: dependencies.restrictionLifecycleRepository,
    );
    restrictionLifecycleSyncCoordinator.attach();

    streaksRepository = dependencies.streaksRepository;

    super.initState();
  }

  @override
  void dispose() {
    // Root-scoped runtime objects are disposed together with UI scope.
    currentUserBloc.close();
    authBloc.close();
    restrictionLifecycleSyncCoordinator.detach();
    blockingRepository.dispose();
    modesRepository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedRootScope(data: this, child: widget.child);
  }
}

class _InheritedRootScope extends InheritedWidget {
  const _InheritedRootScope({required this.data, required super.child});

  final RootScopeState data;

  /// The state from the closest instance of this class
  /// that encloses the given context, if any.
  /// For example: `SettingsScope.maybeOf(context)`.
  static _InheritedRootScope? maybeOf(BuildContext context, {bool listen = true}) => listen
      ? context.dependOnInheritedWidgetOfExactType<_InheritedRootScope>()
      : context.getInheritedWidgetOfExactType<_InheritedRootScope>();

  static Never _notFoundInheritedWidgetOfExactType() => throw ArgumentError(
    'Out of scope, not found inherited widget '
        'a _InheritedRootScope of the exact type',
    'out_of_scope',
  );

  /// The state from the closest instance of this class
  /// that encloses the given context.
  /// For example: `SettingsScope.of(context)`.
  static _InheritedRootScope of(BuildContext context, {bool listen = true}) =>
      maybeOf(context, listen: listen) ?? _notFoundInheritedWidgetOfExactType();

  @override
  bool updateShouldNotify(_InheritedRootScope oldWidget) => false;
}
