import 'package:flutter/widgets.dart';
import 'package:helm/helm.dart';
import 'package:pauza/src/features/home/widget/home_screen.dart';
import 'package:pauza/src/features/modes/add_edit/widgets/mode_editor_screen.dart';
import 'package:pauza/src/features/not_found/widget/not_found_screen.dart';
import 'package:pauza/src/features/permissions/widget/permissions_screen.dart';

enum PauzaRoutes with Routable {
  root,
  home,

  modeCreate,
  modeEdit,

  permissions,
  notFound;

  @override
  String get path => switch (this) {
    PauzaRoutes.root => '/',
    PauzaRoutes.home => '/home',
    PauzaRoutes.modeCreate => '/modes/new',
    PauzaRoutes.modeEdit => '/modes/{midEdit}/edit',
    PauzaRoutes.permissions => '/permissions',
    PauzaRoutes.notFound => '/404',
  };

  @override
  PageType get pageType => switch (this) {
    PauzaRoutes.root ||
    PauzaRoutes.home ||
    PauzaRoutes.modeCreate ||
    PauzaRoutes.modeEdit ||
    PauzaRoutes.permissions ||
    PauzaRoutes.notFound => PageType.material,
  };

  @override
  Widget builder(Map<String, String> pathParams, Map<String, String> queryParams) => switch (this) {
    PauzaRoutes.root => const HomeScreen(),
    PauzaRoutes.home => const HomeScreen(),
    PauzaRoutes.modeCreate => ModeEditorScreen.create(),
    PauzaRoutes.modeEdit => ModeEditorScreen.edit(modeId: pathParams['midEdit'] ?? ''),
    PauzaRoutes.permissions => const PermissionsScreen(),
    PauzaRoutes.notFound => const NotFoundScreen(),
  };
}
