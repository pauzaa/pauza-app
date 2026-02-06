import 'package:flutter/widgets.dart';
import 'package:helm/helm.dart';
import 'package:pauza/src/core/permissions/pauza_permission_requirement.dart';
import 'package:pauza/src/features/home/widget/home_screen.dart';
import 'package:pauza/src/features/modes/widget/confirm_delete_mode_dialog.dart';
import 'package:pauza/src/features/modes/widget/mode_picker_sheet.dart';
import 'package:pauza/src/features/not_found/widget/not_found_screen.dart';
import 'package:pauza/src/features/permissions/widget/android_accessibility_permission_screen.dart';
import 'package:pauza/src/features/permissions/widget/android_usage_access_permission_screen.dart';
import 'package:pauza/src/features/permissions/widget/ios_family_controls_permission_screen.dart';

enum PauzaRoutes with Routable {
  root,
  home,
  modePicker,
  modeDeleteConfirm,
  permissionUsageAccess,
  permissionAccessibility,
  permissionFamilyControls,
  notFound;

  @override
  String get path => switch (this) {
    PauzaRoutes.root => '/',
    PauzaRoutes.home => '/home',
    PauzaRoutes.modePicker => '/mode-picker',
    PauzaRoutes.modeDeleteConfirm => '/modes/{mid}/delete',
    PauzaRoutes.permissionUsageAccess => '/permissions/usage-access',
    PauzaRoutes.permissionAccessibility => '/permissions/accessibility',
    PauzaRoutes.permissionFamilyControls => '/permissions/family-controls',
    PauzaRoutes.notFound => '/404',
  };

  @override
  PageType get pageType => switch (this) {
    PauzaRoutes.modePicker => PageType.bottomSheet,
    PauzaRoutes.modeDeleteConfirm => PageType.dialog,
    PauzaRoutes.root ||
    PauzaRoutes.home ||
    PauzaRoutes.permissionUsageAccess ||
    PauzaRoutes.permissionAccessibility ||
    PauzaRoutes.permissionFamilyControls ||
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
    PauzaRoutes.permissionUsageAccess =>
      const AndroidUsageAccessPermissionScreen(),
    PauzaRoutes.permissionAccessibility =>
      const AndroidAccessibilityPermissionScreen(),
    PauzaRoutes.permissionFamilyControls =>
      const IosFamilyControlsPermissionScreen(),
    PauzaRoutes.notFound => const NotFoundScreen(),
  };
}

extension PauzaPermissionRequirementRouting on PauzaPermissionRequirement {
  PauzaRoutes get route => switch (this) {
    PauzaPermissionRequirement.androidUsageAccess =>
      PauzaRoutes.permissionUsageAccess,
    PauzaPermissionRequirement.androidAccessibility =>
      PauzaRoutes.permissionAccessibility,
    PauzaPermissionRequirement.iosFamilyControls =>
      PauzaRoutes.permissionFamilyControls,
  };
}
