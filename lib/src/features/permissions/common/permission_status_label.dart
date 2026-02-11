import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart' show PermissionStatus;

extension PermissionStatusLabel on PermissionStatus {
  String label(AppLocalizations l10n) =>
      switch (this) {
        PermissionStatus.granted => l10n.permissionStatusGranted,
        PermissionStatus.denied => l10n.permissionStatusDenied,
        PermissionStatus.restricted => l10n.permissionStatusRestricted,
        PermissionStatus.notDetermined => l10n.permissionStatusNotDetermined,
      };
}
