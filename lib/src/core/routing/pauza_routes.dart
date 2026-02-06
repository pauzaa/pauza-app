import 'package:flutter/widgets.dart';
import 'package:helm/helm.dart';
import 'package:pauza/src/features/home/widget/home_screen.dart';
import 'package:pauza/src/features/modes/widget/confirm_delete_mode_dialog.dart';
import 'package:pauza/src/features/modes/widget/mode_picker_sheet.dart';
import 'package:pauza/src/features/not_found/widget/not_found_screen.dart';

enum PauzaRoutes with Routable {
  root,
  home,
  modePicker,
  modeDeleteConfirm,
  notFound;

  @override
  String get path => switch (this) {
    PauzaRoutes.root => '/',
    PauzaRoutes.home => '/home',
    PauzaRoutes.modePicker => '/mode-picker',
    PauzaRoutes.modeDeleteConfirm => '/modes/{mid}/delete',
    PauzaRoutes.notFound => '/404',
  };

  @override
  PageType get pageType => switch (this) {
    PauzaRoutes.modePicker => PageType.bottomSheet,
    PauzaRoutes.modeDeleteConfirm => PageType.dialog,
    PauzaRoutes.root ||
    PauzaRoutes.home ||
    PauzaRoutes.notFound => PageType.material,
  };

  @override
  Widget builder(
    Map<String, String> pathParams,
    Map<String, String> queryParams,
  ) => switch (this) {
    PauzaRoutes.root => const HomeScreen(),
    PauzaRoutes.home => const HomeScreen(),
    PauzaRoutes.modePicker => const ModePickerSheet(),
    PauzaRoutes.modeDeleteConfirm => ConfirmDeleteModeDialog(
      modeId: pathParams['mid'] ?? '',
    ),
    PauzaRoutes.notFound => const NotFoundScreen(),
  };
}
