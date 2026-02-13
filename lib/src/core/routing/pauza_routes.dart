import 'package:flutter/widgets.dart';
import 'package:helm/helm.dart';
import 'package:pauza/src/features/permissions/model/pauza_permission_requirement.dart';
import 'package:pauza/src/features/home/widget/home_screen.dart';
import 'package:pauza/src/features/modes/add_edit/widgets/mode_editor_screen.dart';
import 'package:pauza/src/features/not_found/widget/not_found_screen.dart';
import 'package:pauza/src/features/permissions/widget/android_accessibility_permission_screen.dart';
import 'package:pauza/src/features/permissions/widget/android_exact_alarm_permission_screen.dart';
import 'package:pauza/src/features/permissions/widget/android_usage_access_permission_screen.dart';
import 'package:pauza/src/features/permissions/widget/ios_family_controls_permission_screen.dart';

enum PauzaRoutes with Routable {
  root,
  home,

  modeCreate,
  modeEdit,

  permissionUsageAccess,
  permissionAccessibility,
  permissionExactAlarm,
  permissionFamilyControls,
  notFound;

  @override
  String get path => switch (this) {
    PauzaRoutes.root => '/',
    PauzaRoutes.home => '/home',
    PauzaRoutes.modeCreate => '/modes/new',
    PauzaRoutes.modeEdit => '/modes/{midEdit}/edit',
    PauzaRoutes.permissionUsageAccess => '/permissions/usage-access',
    PauzaRoutes.permissionAccessibility => '/permissions/accessibility',
    PauzaRoutes.permissionExactAlarm => '/permissions/exact-alarm',
    PauzaRoutes.permissionFamilyControls => '/permissions/family-controls',
    PauzaRoutes.notFound => '/404',
  };

  @override
  PageType get pageType => switch (this) {
    PauzaRoutes.root ||
    PauzaRoutes.home ||
    PauzaRoutes.modeCreate ||
    PauzaRoutes.modeEdit ||
    PauzaRoutes.permissionUsageAccess ||
    PauzaRoutes.permissionAccessibility ||
    PauzaRoutes.permissionExactAlarm ||
    PauzaRoutes.permissionFamilyControls ||
    PauzaRoutes.notFound => PageType.material,
  };

  @override
  Widget builder(Map<String, String> pathParams, Map<String, String> queryParams) => switch (this) {
    PauzaRoutes.root => const HomeScreen(),
    PauzaRoutes.home => const HomeScreen(),
    PauzaRoutes.modeCreate => ModeEditorScreen.create(),
    PauzaRoutes.modeEdit => ModeEditorScreen.edit(modeId: pathParams['midEdit'] ?? ''),
    PauzaRoutes.permissionUsageAccess => const AndroidUsageAccessPermissionScreen(),
    PauzaRoutes.permissionAccessibility => const AndroidAccessibilityPermissionScreen(),
    PauzaRoutes.permissionExactAlarm => const AndroidExactAlarmPermissionScreen(),
    PauzaRoutes.permissionFamilyControls => const IosFamilyControlsPermissionScreen(),
    PauzaRoutes.notFound => const NotFoundScreen(),
  };
}

extension PauzaPermissionRequirementRouting on PauzaPermissionRequirement {
  PauzaRoutes get route => switch (this) {
    PauzaPermissionRequirement.androidUsageAccess => PauzaRoutes.permissionUsageAccess,
    PauzaPermissionRequirement.androidAccessibility => PauzaRoutes.permissionAccessibility,
    PauzaPermissionRequirement.androidExactAlarm => PauzaRoutes.permissionExactAlarm,
    PauzaPermissionRequirement.iosFamilyControls => PauzaRoutes.permissionFamilyControls,
  };
}
