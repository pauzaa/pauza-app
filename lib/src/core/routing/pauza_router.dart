import 'package:flutter/widgets.dart';
import 'package:helm/helm.dart';
import 'package:pauza/src/core/routing/pauza_routes.dart';

mixin RouterStateMixin<T extends StatefulWidget> on State<T> {
  late final HelmRouter router;

  @override
  void initState() {
    super.initState();

    router = HelmRouter(
      routes: PauzaRoutes.values,
      guards: <NavigationGuard>[
        (NavigationState pages) =>
            pages.isEmpty ? [PauzaRoutes.notFound.page()] : pages,
        (pages) {
          if (pages.isNotEmpty && pages.first.name != PauzaRoutes.root.path) {
            return [PauzaRoutes.root.page(), ...pages];
          }
          return pages;
        },
      ],
    );
  }
}
