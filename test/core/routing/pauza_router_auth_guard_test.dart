import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:helm/helm.dart';
import 'package:pauza/src/core/routing/pauza_router_guards.dart';
import 'package:pauza/src/core/routing/pauza_routes.dart';

void main() {
  group('router guard flow', () {
    test('unauthenticated + [home] redirects to [auth]', () {
      final result = _applyGuards(
        isAuthenticated: false,
        isReady: true,
        state: <Page<Object?>>[PauzaRoutes.home.page()],
      );

      expect(_routesOf(result), <PauzaRoutes>[PauzaRoutes.auth]);
    });

    test('unauthenticated + [permissions] redirects to [auth]', () {
      final result = _applyGuards(
        isAuthenticated: false,
        isReady: false,
        state: <Page<Object?>>[PauzaRoutes.permissions.page()],
      );

      expect(_routesOf(result), <PauzaRoutes>[PauzaRoutes.auth]);
    });

    test('unauthenticated + [otp, home] keeps auth-flow-only stack', () {
      final result = _applyGuards(
        isAuthenticated: false,
        isReady: true,
        state: <Page<Object?>>[PauzaRoutes.otp.page(), PauzaRoutes.home.page()],
      );

      expect(_routesOf(result), <PauzaRoutes>[PauzaRoutes.otp]);
    });

    test('authenticated + [auth] redirects to [root]', () {
      final result = _applyGuards(
        isAuthenticated: true,
        isReady: true,
        state: <Page<Object?>>[PauzaRoutes.auth.page()],
      );

      expect(_routesOf(result), <PauzaRoutes>[PauzaRoutes.root]);
    });

    test('authenticated + [otp] redirects to [root]', () {
      final result = _applyGuards(isAuthenticated: true, isReady: true, state: <Page<Object?>>[PauzaRoutes.otp.page()]);

      expect(_routesOf(result), <PauzaRoutes>[PauzaRoutes.root]);
    });

    test('authenticated + [profile] becomes [root, profile]', () {
      final result = _applyGuards(
        isAuthenticated: true,
        isReady: true,
        state: <Page<Object?>>[PauzaRoutes.profile.page()],
      );

      expect(_routesOf(result), <PauzaRoutes>[PauzaRoutes.root, PauzaRoutes.profile]);
    });

    test('authenticated + missing permissions overlays permissions on top', () {
      final result = _applyGuards(
        isAuthenticated: true,
        isReady: false,
        state: <Page<Object?>>[PauzaRoutes.root.page(), PauzaRoutes.profile.page()],
      );

      expect(_routesOf(result), <PauzaRoutes>[PauzaRoutes.root, PauzaRoutes.profile, PauzaRoutes.permissions]);
    });

    test('authenticated + permissions ready removes permissions page', () {
      final result = _applyGuards(
        isAuthenticated: true,
        isReady: true,
        state: <Page<Object?>>[PauzaRoutes.root.page(), PauzaRoutes.profile.page(), PauzaRoutes.permissions.page()],
      );

      expect(_routesOf(result), <PauzaRoutes>[PauzaRoutes.root, PauzaRoutes.profile]);
    });

    test('unauthenticated ignores permissions state and keeps auth-only flow', () {
      final result = _applyGuards(
        isAuthenticated: false,
        isReady: false,
        state: <Page<Object?>>[PauzaRoutes.auth.page()],
      );

      expect(_routesOf(result), <PauzaRoutes>[PauzaRoutes.auth]);
    });

    test('duplicate exact pages collapse and keep latest/topmost', () {
      final result = _applyGuards(
        isAuthenticated: true,
        isReady: true,
        state: <Page<Object?>>[PauzaRoutes.profile.page(), PauzaRoutes.profile.page()],
      );

      expect(_routesOf(result), <PauzaRoutes>[PauzaRoutes.root, PauzaRoutes.profile]);
      expect(result.length, 2);
    });

    test('same route with different params are deduplicated by route', () {
      final result = _applyGuards(
        isAuthenticated: true,
        isReady: true,
        state: <Page<Object?>>[
          PauzaRoutes.modeEdit.page(pathParams: <String, String>{'midEdit': '1'}),
          PauzaRoutes.modeEdit.page(pathParams: <String, String>{'midEdit': '2'}),
        ],
      );

      expect(_routesOf(result), <PauzaRoutes>[PauzaRoutes.root, PauzaRoutes.modeEdit]);
      expect(result.length, 2);
      final modeEditPage = result.last;
      expect(modeEditPage.meta?.pathParams, <String, String>{'midEdit': '2'});
    });
  });
}

NavigationState _applyGuards({required bool isAuthenticated, required bool isReady, required NavigationState state}) {
  final guards = <NavigationGuard>[
    createAuthGuard(isAuthenticated: () => isAuthenticated),
    createPermissionGuard(isAuthenticated: () => isAuthenticated, isReady: () => isReady),
  ];
  return guards.fold<NavigationState>(state, (pages, guard) => guard(pages));
}

List<PauzaRoutes> _routesOf(NavigationState pages) {
  return pages.map((page) => page.meta?.route as PauzaRoutes).toList(growable: false);
}
