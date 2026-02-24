import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/core/localization/gen/app_localizations_en.g.dart';
import 'package:pauza/src/features/nfc/model/nfc_chip_availability.dart';

void main() {
  final l10n = AppLocalizationsEn();

  group('NfcChipAvailability', () {
    group('showGuidance', () {
      test('available does not show guidance', () {
        expect(NfcChipAvailability.available.showGuidance, isFalse);
      });

      test('disabled shows guidance', () {
        expect(NfcChipAvailability.disabled.showGuidance, isTrue);
      });

      test('notSupported shows guidance', () {
        expect(NfcChipAvailability.notSupported.showGuidance, isTrue);
      });

      test('unknown shows guidance', () {
        expect(NfcChipAvailability.unknown.showGuidance, isTrue);
      });
    });

    group('showOpenSettingsAction', () {
      test('available does not show open settings action', () {
        expect(NfcChipAvailability.available.showOpenSettingsAction, isFalse);
      });

      test('disabled shows open settings action', () {
        expect(NfcChipAvailability.disabled.showOpenSettingsAction, isTrue);
      });

      test('notSupported does not show open settings action', () {
        expect(NfcChipAvailability.notSupported.showOpenSettingsAction, isFalse);
      });

      test('unknown does not show open settings action', () {
        expect(NfcChipAvailability.unknown.showOpenSettingsAction, isFalse);
      });
    });

    group('severity', () {
      test('available has info severity', () {
        expect(NfcChipAvailability.available.severity, NfcAvailabilitySeverity.info);
      });

      test('disabled has warning severity', () {
        expect(NfcChipAvailability.disabled.severity, NfcAvailabilitySeverity.warning);
      });

      test('notSupported has error severity', () {
        expect(NfcChipAvailability.notSupported.severity, NfcAvailabilitySeverity.error);
      });

      test('unknown has warning severity', () {
        expect(NfcChipAvailability.unknown.severity, NfcAvailabilitySeverity.warning);
      });
    });

    group('shouldShowOpenSettings', () {
      test('disabled with canOpenSettings=true shows open settings action', () {
        expect(NfcChipAvailability.disabled.shouldShowOpenSettings(canOpenSettings: true), isTrue);
      });

      test('disabled with canOpenSettings=false hides open settings action', () {
        expect(NfcChipAvailability.disabled.shouldShowOpenSettings(canOpenSettings: false), isFalse);
      });

      test('other values always return false regardless of canOpenSettings', () {
        expect(NfcChipAvailability.available.shouldShowOpenSettings(canOpenSettings: true), isFalse);
        expect(NfcChipAvailability.notSupported.shouldShowOpenSettings(canOpenSettings: true), isFalse);
        expect(NfcChipAvailability.unknown.shouldShowOpenSettings(canOpenSettings: true), isFalse);
      });
    });

    group('localizedTitle', () {
      test('available returns correct title', () {
        expect(NfcChipAvailability.available.localizedTitle(l10n), 'NFC is ready');
      });

      test('disabled returns correct title', () {
        expect(NfcChipAvailability.disabled.localizedTitle(l10n), 'Turn on NFC');
      });

      test('notSupported returns correct title', () {
        expect(NfcChipAvailability.notSupported.localizedTitle(l10n), 'NFC is not supported');
      });

      test('unknown returns correct title', () {
        expect(NfcChipAvailability.unknown.localizedTitle(l10n), 'NFC status unavailable');
      });
    });

    group('localizedBody', () {
      test('available returns correct body', () {
        expect(NfcChipAvailability.available.localizedBody(l10n), 'Your device is ready to scan NFC tags.');
      });

      test('disabled returns correct body', () {
        expect(
          NfcChipAvailability.disabled.localizedBody(l10n),
          'NFC is turned off on this device. Enable it in system settings to continue.',
        );
      });

      test('notSupported returns correct body', () {
        expect(NfcChipAvailability.notSupported.localizedBody(l10n), 'This device does not support NFC scanning.');
      });

      test('unknown returns correct body', () {
        expect(
          NfcChipAvailability.unknown.localizedBody(l10n),
          'We could not determine NFC availability right now. Try again in a moment.',
        );
      });
    });

    group('localizedActionLabel', () {
      test('available returns null', () {
        expect(NfcChipAvailability.available.localizedActionLabel(l10n, canOpenSettings: true), isNull);
      });

      test('disabled with canOpenSettings=true returns action label', () {
        expect(NfcChipAvailability.disabled.localizedActionLabel(l10n, canOpenSettings: true), 'Open settings');
      });

      test('disabled with canOpenSettings=false returns null', () {
        expect(NfcChipAvailability.disabled.localizedActionLabel(l10n, canOpenSettings: false), isNull);
      });

      test('notSupported returns null', () {
        expect(NfcChipAvailability.notSupported.localizedActionLabel(l10n, canOpenSettings: true), isNull);
      });

      test('unknown returns null', () {
        expect(NfcChipAvailability.unknown.localizedActionLabel(l10n, canOpenSettings: true), isNull);
      });
    });
  });

  group('NfcAvailabilitySeverity', () {
    test('has info, warning, and error values', () {
      expect(NfcAvailabilitySeverity.values, hasLength(3));
      expect(
        NfcAvailabilitySeverity.values,
        containsAll([NfcAvailabilitySeverity.info, NfcAvailabilitySeverity.warning, NfcAvailabilitySeverity.error]),
      );
    });
  });
}
