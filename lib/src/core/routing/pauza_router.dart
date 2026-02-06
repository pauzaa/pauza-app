import 'package:flutter/widgets.dart';
import 'package:helm/helm.dart';
import 'package:pauza/src/core/permissions/permission_helper.dart';
import 'package:pauza/src/core/routing/pauza_routes.dart';

mixin RouterStateMixin<T extends StatefulWidget> on State<T> {
  PauzaPermissionGate get permissionGate;

  late final HelmRouter router;
  NavigationState? _pendingStack;

  @override
  void initState() {
    super.initState();

    router = HelmRouter(
      routes: PauzaRoutes.values,
      refresh: permissionGate,
      guards: <NavigationGuard>[
        (NavigationState pages) =>
            pages.isEmpty ? [PauzaRoutes.notFound.page()] : pages,
        (pages) {
          if (pages.isNotEmpty && pages.first.name != PauzaRoutes.root.path) {
            return [PauzaRoutes.root.page(), ...pages];
          }
          return pages;
        },
        (pages) {
          final missingRequirement = permissionGate.state.firstMissing;
          if (missingRequirement == null) {
            final pending = _pendingStack;
            if (pending == null) {
              return pages;
            }

            _pendingStack = null;
            return _sameStack(pending, pages) ? pages : pending;
          }

          final guardedPages = <Page<Object?>>[
            PauzaRoutes.root.page(),
            missingRequirement.route.page(),
          ];
          final isAlreadyGuarded = _sameStack(pages, guardedPages);

          if (!isAlreadyGuarded && _pendingStack == null) {
            _pendingStack = pages;
          }

          return isAlreadyGuarded ? pages : guardedPages;
        },
      ],
    );
  }

  bool _sameStack(NavigationState left, NavigationState right) {
    if (left.length != right.length) {
      return false;
    }

    for (var i = 0; i < left.length; i++) {
      final l = left[i];
      final r = right[i];

      if (l.name != r.name) {
        return false;
      }

      final lMeta = l.meta;
      final rMeta = r.meta;
      if (lMeta?.route != rMeta?.route) {
        return false;
      }
      if (!_sameMaps(lMeta?.pathParams, rMeta?.pathParams)) {
        return false;
      }
      if (!_sameMaps(lMeta?.queryParams, rMeta?.queryParams)) {
        return false;
      }

      final lChildren = lMeta?.children;
      final rChildren = rMeta?.children;
      if (lChildren == null || rChildren == null) {
        if (lChildren != rChildren) {
          return false;
        }
        continue;
      }
      if (!_sameStack(lChildren, rChildren)) {
        return false;
      }
    }

    return true;
  }

  bool _sameMaps(Map<String, String>? left, Map<String, String>? right) {
    final leftMap = left ?? const <String, String>{};
    final rightMap = right ?? const <String, String>{};
    if (leftMap.length != rightMap.length) {
      return false;
    }

    for (final entry in leftMap.entries) {
      if (rightMap[entry.key] != entry.value) {
        return false;
      }
    }
    return true;
  }
}
