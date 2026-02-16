import 'package:helm/helm.dart';
import 'package:pauza/src/core/routing/pauza_routes.dart';

NavigationState normalizeNavigationToRootShell(NavigationState pages) {
  if (pages.isEmpty) {
    return [PauzaRoutes.notFound.page()];
  }

  if (_containsStandaloneRoute(pages)) {
    return pages;
  }

  final rootPage = pages.firstWhere(
    (page) => page.meta?.route == PauzaRoutes.root,
    orElse: () => PauzaRoutes.root.page(),
  );

  final topLevelPages = pages
      .where((page) => page.meta?.route != PauzaRoutes.root)
      .toList(growable: false);

  return [rootPage, ...topLevelPages];
}

NavigationGuard createPermissionGuard({
  required bool Function() isReady,
  required NavigationState Function(NavigationState pages) normalize,
  required NavigationState? Function() readPending,
  required void Function(NavigationState?) writePending,
}) {
  return (pages) {
    if (isReady()) {
      final pending = readPending();
      writePending(null);
      return pending ?? pages;
    }

    final isOnPermissionsScreen = pages.any((page) => page.meta?.route == PauzaRoutes.permissions);

    if (!isOnPermissionsScreen) {
      writePending(pages);
    }

    return isOnPermissionsScreen ? pages : normalize([PauzaRoutes.permissions.page()]);
  };
}

NavigationGuard createAuthGuard({
  required bool Function() isAuthenticated,
  required NavigationState Function(NavigationState pages) normalize,
  required NavigationState? Function() readPending,
  required void Function(NavigationState?) writePending,
}) {
  return (pages) {
    final isOnPermissionsScreen = pages.any((page) => page.meta?.route == PauzaRoutes.permissions);
    if (isOnPermissionsScreen) {
      return pages;
    }

    final isOnAuthFlow = pages.any((page) {
      final route = page.meta?.route;
      return route == PauzaRoutes.auth || route == PauzaRoutes.otp;
    });

    if (isAuthenticated()) {
      if (isOnAuthFlow) {
        final pending = readPending();
        writePending(null);
        return pending ?? normalize([PauzaRoutes.home.page()]);
      }
      return pages;
    }

    if (!isOnAuthFlow) {
      writePending(pages);
      return normalize([PauzaRoutes.auth.page()]);
    }

    return pages;
  };
}

bool _containsStandaloneRoute(NavigationState pages) {
  return pages.any((page) {
    final route = page.meta?.route;
    return route == PauzaRoutes.permissions ||
        route == PauzaRoutes.auth ||
        route == PauzaRoutes.otp;
  });
}
