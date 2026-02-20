import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:helm/helm.dart';
import 'package:pauza/src/core/routing/pauza_routes.dart';

NavigationGuard createPermissionGuard({required bool Function() isAuthenticated, required bool Function() isReady}) {
  return (pages) {
    if (!isAuthenticated()) {
      return _dedupeState(pages);
    }

    final normalizedPages = _normalizeAuthenticatedStack(pages);
    final withoutPermissions = _removeRouteAll(normalizedPages, PauzaRoutes.permissions);

    if (isReady()) {
      return _dedupeState(withoutPermissions);
    }

    return _dedupeState(<Page<Object?>>[...withoutPermissions, PauzaRoutes.permissions.page()]);
  };
}

NavigationGuard createAuthGuard({required bool Function() isAuthenticated}) {
  return (pages) {
    final dedupedPages = _dedupeState(pages);

    if (!isAuthenticated()) {
      return _authOnlyStack(dedupedPages);
    }

    final isOnAuthFlow =
        _containsRoute(dedupedPages, PauzaRoutes.auth) || _containsRoute(dedupedPages, PauzaRoutes.otp);
    if (isOnAuthFlow) {
      return <Page<Object?>>[PauzaRoutes.root.page()];
    }

    return _normalizeAuthenticatedStack(dedupedPages);
  };
}

NavigationState _normalizeAuthenticatedStack(NavigationState pages) {
  var normalizedPages = _removeRouteAll(pages, PauzaRoutes.auth);
  normalizedPages = _removeRouteAll(normalizedPages, PauzaRoutes.otp);
  normalizedPages = _dedupeState(normalizedPages);

  final rootPage = normalizedPages.firstWhere(
    (page) => _routeOf(page) == PauzaRoutes.root,
    orElse: () => PauzaRoutes.root.page(),
  );
  final topLevelPages = normalizedPages.where((page) => _routeOf(page) != PauzaRoutes.root).toList(growable: false);
  return _dedupeState(<Page<Object?>>[rootPage, ...topLevelPages]);
}

NavigationState _authOnlyStack(NavigationState pages) {
  final authFlowPages = pages.where((page) => _isAuthFlowRoute(_routeOf(page))).toList(growable: false);
  if (authFlowPages.isEmpty) {
    return <Page<Object?>>[PauzaRoutes.auth.page()];
  }
  return _dedupeState(authFlowPages);
}

NavigationState _removeRouteAll(NavigationState pages, PauzaRoutes route) {
  return pages.removeAllByRoute(route, recursive: true);
}

NavigationState _dedupeState(NavigationState pages) {
  final pagesWithDedupedChildren = pages.map(_withDedupedChildren).toList(growable: false);

  final signatures = <String>{};
  final deduped = <Page<Object?>>[];
  for (var i = pagesWithDedupedChildren.length - 1; i >= 0; i--) {
    final page = pagesWithDedupedChildren[i];
    final signature = _pageSignature(page);
    if (signatures.add(signature)) {
      deduped.insert(0, page);
    }
  }

  return deduped;
}

Page<Object?> _withDedupedChildren(Page<Object?> page) {
  final meta = page.meta;
  final children = meta?.children;
  if (meta == null || children == null || children.isEmpty) {
    return page;
  }

  final dedupedChildren = _dedupeState(children);
  if (listEquals(children, dedupedChildren)) {
    return page;
  }

  final nextMeta = meta.copyWith(children: () => dedupedChildren);
  return meta.route.build(page.key, page.name ?? meta.route.path, nextMeta);
}

bool _containsRoute(NavigationState pages, PauzaRoutes route) {
  return pages.any((page) => _routeOf(page) == route);
}

bool _isAuthFlowRoute(PauzaRoutes? route) {
  return route == PauzaRoutes.auth || route == PauzaRoutes.otp;
}

PauzaRoutes? _routeOf(Page<Object?> page) {
  return page.meta?.route as PauzaRoutes?;
}

String _pageSignature(Page<Object?> page) {
  final meta = page.meta;
  if (meta == null) {
    return 'unknown:${page.runtimeType}:${page.name ?? ''}';
  }

  final route = meta.route;
  if (route is! PauzaRoutes) {
    return 'unknown-route:${route.path}:${page.name ?? ''}';
  }

  return route.name;
}
