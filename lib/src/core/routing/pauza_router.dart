import 'package:appfuse/appfuse.dart';
import 'package:flutter/widgets.dart';
import 'package:helm/helm.dart';
import 'package:pauza/src/core/init/pauza_dependencies.dart';
import 'package:pauza/src/core/routing/pauza_router_guards.dart';
import 'package:pauza/src/core/routing/pauza_routes.dart';
import 'package:pauza/src/features/auth/domain/auth_gate.dart';
import 'package:pauza/src/features/onboarding/widget/onboarding_screen.dart';
import 'package:pauza/src/features/permissions/domain/permission_gate.dart';

mixin RouterStateMixin<T extends StatefulWidget> on State<T> {
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
        _onboardingGuard(),
        _authGuard(authGate),
        _permissionGuard(permissionGate, authGate),
      ],
    );
  }

  NavigationGuard _onboardingGuard() {
    return createOnboardingGuard(
      isFirstLaunch: () => context.readFuseState.metaData.isFirstLaunch,
      isCompleted: () => context.readFuseState.getCustomSetting<bool>(onboardingCompletedKey) ?? false,
    );
  }

  NavigationState _emptyPageGuard(NavigationState pages) {
    return pages.isEmpty ? [PauzaRoutes.notFound.page()] : pages;
  }

  NavigationGuard _permissionGuard(PauzaPermissionGate permissionGate, PauzaAuthGate authGate) {
    return createPermissionGuard(
      isAuthenticated: () => authGate.isAuthenticated,
      isReady: () => permissionGate.state.isReady,
    );
  }

  NavigationGuard _authGuard(PauzaAuthGate authGate) {
    return createAuthGuard(isAuthenticated: () => authGate.isAuthenticated);
  }
}
