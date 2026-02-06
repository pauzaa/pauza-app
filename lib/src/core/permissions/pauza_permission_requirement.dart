import 'package:flutter/foundation.dart';
import 'package:pauza/src/core/localization/gen/app_localizations.dart';
import 'package:pauza/src/core/permissions/permission_gate_state.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart'
    show AndroidPermission, IOSPermission;

enum PauzaPermissionRequirement {
  androidUsageAccess(
    id: 'android_usage_access',
    routePath: '/permissions/usage-access',
    titleL10nKey: 'permissionUsageAccessTitle',
    whyL10nKey: 'permissionUsageAccessBody',
    androidPermission: AndroidPermission.usageStats,
  ),
  androidAccessibility(
    id: 'android_accessibility',
    routePath: '/permissions/accessibility',
    titleL10nKey: 'permissionAccessibilityTitle',
    whyL10nKey: 'permissionAccessibilityBody',
    androidPermission: AndroidPermission.accessibility,
  ),
  iosFamilyControls(
    id: 'ios_family_controls',
    routePath: '/permissions/family-controls',
    titleL10nKey: 'permissionFamilyControlsTitle',
    whyL10nKey: 'permissionFamilyControlsBody',
    iosPermission: IOSPermission.familyControls,
  );

  const PauzaPermissionRequirement({
    required this.id,
    required this.routePath,
    required this.titleL10nKey,
    required this.whyL10nKey,
    this.androidPermission,
    this.iosPermission,
  });

  final String id;
  final String routePath;
  final String titleL10nKey;
  final String whyL10nKey;
  final AndroidPermission? androidPermission;
  final IOSPermission? iosPermission;

  static List<PauzaPermissionRequirement> requiredForCurrentPlatform() {
    if (kIsWeb) {
      return const <PauzaPermissionRequirement>[];
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => const <PauzaPermissionRequirement>[
        PauzaPermissionRequirement.androidUsageAccess,
        PauzaPermissionRequirement.androidAccessibility,
      ],
      TargetPlatform.iOS => const <PauzaPermissionRequirement>[
        PauzaPermissionRequirement.iosFamilyControls,
      ],
      TargetPlatform.fuchsia ||
      TargetPlatform.linux ||
      TargetPlatform.macOS ||
      TargetPlatform.windows => const <PauzaPermissionRequirement>[],
    };
  }

  static PauzaPermissionRequirement? firstMissing(PermissionGateState state) {
    for (final requirement in requiredForCurrentPlatform()) {
      final status = state.statusOf(requirement);
      if (!status.isGranted) {
        return requirement;
      }
    }
    return null;
  }

  String title(AppLocalizations l10n) {
    return switch (this) {
      PauzaPermissionRequirement.androidUsageAccess =>
        l10n.permissionUsageAccessTitle,
      PauzaPermissionRequirement.androidAccessibility =>
        l10n.permissionAccessibilityTitle,
      PauzaPermissionRequirement.iosFamilyControls =>
        l10n.permissionFamilyControlsTitle,
    };
  }

  String body(AppLocalizations l10n) {
    return switch (this) {
      PauzaPermissionRequirement.androidUsageAccess =>
        l10n.permissionUsageAccessBody,
      PauzaPermissionRequirement.androidAccessibility =>
        l10n.permissionAccessibilityBody,
      PauzaPermissionRequirement.iosFamilyControls =>
        l10n.permissionFamilyControlsBody,
    };
  }

  String primaryActionLabel(AppLocalizations l10n) {
    return switch (this) {
      PauzaPermissionRequirement.androidUsageAccess ||
      PauzaPermissionRequirement.androidAccessibility =>
        l10n.permissionOpenSettingsButton,
      PauzaPermissionRequirement.iosFamilyControls =>
        l10n.permissionAllowAccessButton,
    };
  }
}
