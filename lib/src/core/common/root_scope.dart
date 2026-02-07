import 'package:appfuse/appfuse.dart';
import 'package:flutter/material.dart';
import 'package:pauza/src/core/common/pauza_dependencies.dart';
import 'package:pauza/src/features/home/data/app_fuse_active_mode_storage.dart';
import 'package:pauza/src/features/home/data/pauza_screen_time_blocking_repository.dart';
import 'package:pauza/src/features/modes/add_edit/data/pauza_screen_time_installed_apps_repository.dart';
import 'package:pauza/src/features/modes/common/data/modes_repository.dart';

class RootScope extends StatefulWidget {
  const RootScope({required this.child, super.key});

  final Widget child;

  @override
  State<RootScope> createState() => RootScopeState();

  static RootScopeState of(BuildContext context, {bool listen = false}) =>
      _InheritedRootScope.of(context, listen: listen).data;
}

class RootScopeState extends State<RootScope> {
  late final BlockingRepository blockingRepository;
  late final ModesRepository modesRepository;
  late final InstalledAppsRepository installedAppsRepository;

  @override
  void initState() {
    blockingRepository = PauzaScreenTimeBlockingRepository(
      activeModeStorage: AppFuseActiveModeStorage(
        fuseController: AppFuseScope.controller(context),
      ),
    );
    modesRepository = ModesRepositoryImpl(
      localDatabase: PauzaDependencies.of(context).localDatabase,
    );
    installedAppsRepository = PauzaScreenTimeInstalledAppsRepository();
    super.initState();
  }

  @override
  void dispose() {
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
  static _InheritedRootScope? maybeOf(
    BuildContext context, {
    bool listen = true,
  }) => listen
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
