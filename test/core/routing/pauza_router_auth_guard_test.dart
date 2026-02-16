import 'package:flutter_test/flutter_test.dart';
import 'package:helm/helm.dart';
import 'package:pauza/src/core/routing/pauza_router_guards.dart';
import 'package:pauza/src/core/routing/pauza_routes.dart';

void main() {
  group('router guard flow', () {
    test('permissions missing always redirects to permissions first', () {
      NavigationState? permissionPending;
      NavigationState? authPending;

      final guards = <NavigationGuard>[
        normalizeNavigationToRootShell,
        createPermissionGuard(
          isReady: () => false,
          normalize: normalizeNavigationToRootShell,
          readPending: () => permissionPending,
          writePending: (value) => permissionPending = value,
        ),
        createAuthGuard(
          isAuthenticated: () => false,
          normalize: normalizeNavigationToRootShell,
          readPending: () => authPending,
          writePending: (value) => authPending = value,
        ),
      ];

      final result = _applyGuards(guards, [PauzaRoutes.home.page()]);

      expect(result.single.meta?.route, PauzaRoutes.permissions);
      expect(permissionPending, isNotNull);
      expect(authPending, isNull);
    });

    test('permissions ready and unauthenticated redirects to auth', () {
      NavigationState? permissionPending;
      NavigationState? authPending;

      final guards = <NavigationGuard>[
        normalizeNavigationToRootShell,
        createPermissionGuard(
          isReady: () => true,
          normalize: normalizeNavigationToRootShell,
          readPending: () => permissionPending,
          writePending: (value) => permissionPending = value,
        ),
        createAuthGuard(
          isAuthenticated: () => false,
          normalize: normalizeNavigationToRootShell,
          readPending: () => authPending,
          writePending: (value) => authPending = value,
        ),
      ];

      final result = _applyGuards(guards, [PauzaRoutes.home.page()]);

      expect(result.single.meta?.route, PauzaRoutes.auth);
      expect(authPending, isNotNull);
    });

    test('authenticated user on auth route goes to pending route or home', () {
      NavigationState? permissionPending;
      NavigationState? authPending = [PauzaRoutes.stats.page()];

      final guards = <NavigationGuard>[
        normalizeNavigationToRootShell,
        createPermissionGuard(
          isReady: () => true,
          normalize: normalizeNavigationToRootShell,
          readPending: () => permissionPending,
          writePending: (value) => permissionPending = value,
        ),
        createAuthGuard(
          isAuthenticated: () => true,
          normalize: normalizeNavigationToRootShell,
          readPending: () => authPending,
          writePending: (value) => authPending = value,
        ),
      ];

      final result = _applyGuards(guards, [PauzaRoutes.auth.page()]);

      expect(result.single.meta?.route, PauzaRoutes.stats);
      expect(authPending, isNull);
    });

    test('authenticated navigation does not redirect to auth', () {
      NavigationState? permissionPending;
      NavigationState? authPending;

      final guards = <NavigationGuard>[
        normalizeNavigationToRootShell,
        createPermissionGuard(
          isReady: () => true,
          normalize: normalizeNavigationToRootShell,
          readPending: () => permissionPending,
          writePending: (value) => permissionPending = value,
        ),
        createAuthGuard(
          isAuthenticated: () => true,
          normalize: normalizeNavigationToRootShell,
          readPending: () => authPending,
          writePending: (value) => authPending = value,
        ),
      ];

      final result = _applyGuards(guards, [PauzaRoutes.profile.page()]);

      expect(result.last.meta?.route, PauzaRoutes.profile);
      expect(authPending, isNull);
    });
  });
}

NavigationState _applyGuards(
  List<NavigationGuard> guards,
  NavigationState state,
) {
  return guards.fold<NavigationState>(state, (pages, guard) => guard(pages));
}
