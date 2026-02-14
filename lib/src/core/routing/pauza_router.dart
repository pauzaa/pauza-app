import 'package:flutter/widgets.dart';
import 'package:helm/helm.dart';
import 'package:pauza/src/core/common/pauza_dependencies.dart';
import 'package:pauza/src/core/routing/pauza_routes.dart';
import 'package:pauza/src/features/permissions/domain/permission_gate.dart';

mixin RouterStateMixin<T extends StatefulWidget> on State<T> {
  NavigationState? _pendingStack;

  late final HelmRouter router;

  @override
  void initState() {
    super.initState();

    final permissionGate = PauzaDependencies.of(context).permissionGate;

    router = HelmRouter(
      routes: PauzaRoutes.values,
      refresh: permissionGate,
      guards: <NavigationGuard>[
        _emptyPageGuard,
        _normalizeToRootShell,
        _permissionGuard(permissionGate),
      ],
    );
  }

  NavigationState _emptyPageGuard(NavigationState pages) {
    return pages.isEmpty ? [PauzaRoutes.notFound.page()] : pages;
  }

  NavigationState _normalizeToRootShell(NavigationState pages) {
    final rootPage = pages.firstWhere(
      (page) => page.meta?.route == PauzaRoutes.root,
      orElse: () => PauzaRoutes.root.page(),
    );

    final topLevelPages = pages.where((page) => page.meta?.route != PauzaRoutes.root).toList();

    return [rootPage, ...topLevelPages];
  }

  NavigationGuard _permissionGuard(PauzaPermissionGate permissionGate) {
    return (pages) {
      final isReady = permissionGate.state.isReady;

      if (isReady) {
        final pending = _pendingStack;
        _pendingStack = null;
        return pending ?? pages;
      }

      final isOnPermissionsScreen = pages.any(
        (page) => page.meta?.route == PauzaRoutes.permissions,
      );

      if (!isOnPermissionsScreen) {
        _pendingStack = pages;
      }

      return isOnPermissionsScreen
          ? pages
          : _normalizeToRootShell([PauzaRoutes.permissions.page()]);
    };
  }
}
