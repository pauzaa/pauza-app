import 'package:pauza/src/core/localization/gen/app_localizations.g.dart';

enum NfcAvailabilitySeverity { info, warning, error }

enum NfcChipAvailability {
  available(showGuidance: false, showOpenSettingsAction: false, severity: NfcAvailabilitySeverity.info),
  disabled(showGuidance: true, showOpenSettingsAction: true, severity: NfcAvailabilitySeverity.warning),
  notSupported(showGuidance: true, showOpenSettingsAction: false, severity: NfcAvailabilitySeverity.error),
  unknown(showGuidance: true, showOpenSettingsAction: false, severity: NfcAvailabilitySeverity.warning);

  const NfcChipAvailability({required this.showGuidance, required this.showOpenSettingsAction, required this.severity});

  final bool showGuidance;
  final bool showOpenSettingsAction;
  final NfcAvailabilitySeverity severity;

  bool shouldShowOpenSettings({required bool canOpenSettings}) {
    return showOpenSettingsAction && canOpenSettings;
  }

  String localizedTitle(AppLocalizations l10n) {
    return switch (this) {
      NfcChipAvailability.available => l10n.nfcGuidanceAvailableTitle,
      NfcChipAvailability.disabled => l10n.nfcGuidanceDisabledTitle,
      NfcChipAvailability.notSupported => l10n.nfcGuidanceNotSupportedTitle,
      NfcChipAvailability.unknown => l10n.nfcGuidanceUnknownTitle,
    };
  }

  String localizedBody(AppLocalizations l10n) {
    return switch (this) {
      NfcChipAvailability.available => l10n.nfcGuidanceAvailableBody,
      NfcChipAvailability.disabled => l10n.nfcGuidanceDisabledBody,
      NfcChipAvailability.notSupported => l10n.nfcGuidanceNotSupportedBody,
      NfcChipAvailability.unknown => l10n.nfcGuidanceUnknownBody,
    };
  }

  String? localizedActionLabel(AppLocalizations l10n, {required bool canOpenSettings}) {
    return shouldShowOpenSettings(canOpenSettings: canOpenSettings) ? l10n.nfcOpenSettingsButton : null;
  }
}
