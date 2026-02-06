import 'package:flutter/widgets.dart';
import 'package:helm/helm.dart';
import 'package:pauza/src/features/home/widget/home_screen.dart';
import 'package:pauza/src/features/not_found/widget/not_found_screen.dart';

enum PauzaRoutes with Routable {
  root,
  home,
  notFound;

  @override
  String get path => switch (this) {
    PauzaRoutes.root => '/',
    PauzaRoutes.home => '/home',
    PauzaRoutes.notFound => '/404',
  };

  @override
  PageType get pageType => PageType.material;

  @override
  Widget builder(
    Map<String, String> pathParams,
    Map<String, String> queryParams,
  ) => switch (this) {
    PauzaRoutes.root => const HomeScreen(),
    PauzaRoutes.home => const HomeScreen(),
    PauzaRoutes.notFound => const NotFoundScreen(),
  };
}
