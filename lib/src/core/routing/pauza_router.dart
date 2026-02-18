import 'package:flutter/widgets.dart';
import 'package:helm/helm.dart';
import 'package:pauza/src/core/init/pauza_dependencies.dart';
import 'package:pauza/src/core/routing/pauza_router_guards.dart';
import 'package:pauza/src/core/routing/pauza_routes.dart';
import 'package:pauza/src/features/auth/domain/auth_gate.dart';
import 'package:pauza/src/features/permissions/domain/permission_gate.dart';

mixin RouterStateMixin<T extends StatefulWidget> on State<T> {
  NavigationState? _pendingAfterPermissions;
  NavigationState? _pendingAfterAuth;

  late final HelmRouter router;

  @override
  void initState() {
    super.initState();

    final dependencies = PauzaDependencies.of(context);
    final permissionGate = dependencies.permissionGate;
    final authGate = dependencies.authGate;

    router = HelmRouter(
      routes: PauzaRoutes.values,
      refresh: Listenable.merge(<Listenable>[permissionGate, authGate]),
      guards: <NavigationGuard>[
        _emptyPageGuard,
        _normalizeToRootShell,
        _permissionGuard(permissionGate),
        _authGuard(authGate),
      ],
    );
  }

  NavigationState _emptyPageGuard(NavigationState pages) {
    return pages.isEmpty ? [PauzaRoutes.notFound.page()] : pages;
  }

  NavigationState _normalizeToRootShell(NavigationState pages) {
    return normalizeNavigationToRootShell(pages);
  }

  NavigationGuard _permissionGuard(PauzaPermissionGate permissionGate) {
    return createPermissionGuard(
      isReady: () => permissionGate.state.isReady,
      normalize: _normalizeToRootShell,
      readPending: () => _pendingAfterPermissions,
      writePending: (pending) {
        _pendingAfterPermissions = pending;
      },
    );
  }

  NavigationGuard _authGuard(PauzaAuthGate authGate) {
    return createAuthGuard(
      isAuthenticated: () => authGate.isAuthenticated,
      normalize: _normalizeToRootShell,
      readPending: () => _pendingAfterAuth,
      writePending: (pending) {
        _pendingAfterAuth = pending;
      },
    );
  }
}
