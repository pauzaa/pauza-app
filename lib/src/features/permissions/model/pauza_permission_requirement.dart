import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart'
    show AndroidPermission, IOSPermission, PermissionStatus;

enum PauzaPermissionRequirement {
  androidUsageAccess(id: 'android_usage_access', androidPermission: AndroidPermission.usageStats),
  androidAccessibility(
    id: 'android_accessibility',
    androidPermission: AndroidPermission.accessibility,
  ),
  androidExactAlarm(id: 'android_exact_alarm', androidPermission: AndroidPermission.exactAlarm),
  iosFamilyControls(id: 'ios_family_controls', iosPermission: IOSPermission.familyControls);

  const PauzaPermissionRequirement({required this.id, this.androidPermission, this.iosPermission});

  final String id;
  final AndroidPermission? androidPermission;
  final IOSPermission? iosPermission;

  static List<PauzaPermissionRequirement> get requiredForCurrentPlatform {
    if (kIsWeb) {
      return const <PauzaPermissionRequirement>[];
    }

    if (Platform.isAndroid) {
      return const <PauzaPermissionRequirement>[
        PauzaPermissionRequirement.androidUsageAccess,
        PauzaPermissionRequirement.androidAccessibility,
        PauzaPermissionRequirement.androidExactAlarm,
      ];
    }
    if (Platform.isIOS) {
      return const <PauzaPermissionRequirement>[PauzaPermissionRequirement.iosFamilyControls];
    }
    return [];
  }

  String title(AppLocalizations l10n) {
    return switch (this) {
      PauzaPermissionRequirement.androidUsageAccess => l10n.permissionUsageAccessTitle,
      PauzaPermissionRequirement.androidAccessibility => l10n.permissionAccessibilityTitle,
      PauzaPermissionRequirement.androidExactAlarm => l10n.permissionExactAlarmTitle,
      PauzaPermissionRequirement.iosFamilyControls => l10n.permissionFamilyControlsTitle,
    };
  }

  String body(AppLocalizations l10n) {
    return switch (this) {
      PauzaPermissionRequirement.androidUsageAccess => l10n.permissionUsageAccessBody,
      PauzaPermissionRequirement.androidAccessibility => l10n.permissionAccessibilityBody,
      PauzaPermissionRequirement.androidExactAlarm => l10n.permissionExactAlarmBody,
      PauzaPermissionRequirement.iosFamilyControls => l10n.permissionFamilyControlsBody,
    };
  }

  String primaryActionLabel(AppLocalizations l10n) {
    return switch (this) {
      PauzaPermissionRequirement.androidUsageAccess ||
      PauzaPermissionRequirement.androidAccessibility ||
      PauzaPermissionRequirement.androidExactAlarm => l10n.permissionOpenSettingsButton,
      PauzaPermissionRequirement.iosFamilyControls => l10n.permissionAllowAccessButton,
    };
  }

  String shortBody(AppLocalizations l10n) {
    return switch (this) {
      PauzaPermissionRequirement.androidUsageAccess => l10n.permissionUsageAccessShortBody,
      PauzaPermissionRequirement.androidAccessibility => l10n.permissionAccessibilityShortBody,
      PauzaPermissionRequirement.androidExactAlarm => l10n.permissionExactAlarmShortBody,
      PauzaPermissionRequirement.iosFamilyControls => l10n.permissionFamilyControlsShortBody,
    };
  }

  IconData get iconData {
    return switch (this) {
      PauzaPermissionRequirement.androidUsageAccess => Icons.query_stats,
      PauzaPermissionRequirement.androidAccessibility => Icons.accessibility_new,
      PauzaPermissionRequirement.androidExactAlarm => Icons.alarm_on,
      PauzaPermissionRequirement.iosFamilyControls => Icons.family_restroom,
    };
  }
}

extension PermissionStatusLabel on PermissionStatus {
  String label(AppLocalizations l10n) => switch (this) {
    PermissionStatus.granted => l10n.permissionStatusGranted,
    PermissionStatus.denied => l10n.permissionStatusDenied,
    PermissionStatus.restricted => l10n.permissionStatusRestricted,
    PermissionStatus.notDetermined => l10n.permissionStatusNotDetermined,
  };
}
