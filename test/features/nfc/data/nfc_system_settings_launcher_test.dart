import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/features/nfc/data/nfc_system_settings_launcher.dart';

void main() {
  group('AndroidIntentNfcSystemSettingsLauncher', () {
    test('is unsupported on non-Android platforms', () async {
      final launcher = AndroidIntentNfcSystemSettingsLauncher(isAndroidPlatform: false);

      expect(launcher.isSupported, isFalse);
      expect(await launcher.openNfcSettings(), isFalse);
    });

    test('returns true when NFC settings intent succeeds', () async {
      final launcher = AndroidIntentNfcSystemSettingsLauncher(
        isAndroidPlatform: true,
        openNfcSettingsIntent: () async {},
        openWirelessSettingsIntent: () async {
          fail('wireless fallback should not be called');
        },
      );

      final opened = await launcher.openNfcSettings();

      expect(opened, isTrue);
    });

    test('falls back to wireless settings when NFC settings fails', () async {
      var fallbackCalled = false;
      final launcher = AndroidIntentNfcSystemSettingsLauncher(
        isAndroidPlatform: true,
        openNfcSettingsIntent: () async {
          throw StateError('nfc action unavailable');
        },
        openWirelessSettingsIntent: () async {
          fallbackCalled = true;
        },
      );

      final opened = await launcher.openNfcSettings();

      expect(opened, isTrue);
      expect(fallbackCalled, isTrue);
    });

    test('returns false when both intents fail', () async {
      final launcher = AndroidIntentNfcSystemSettingsLauncher(
        isAndroidPlatform: true,
        openNfcSettingsIntent: () async {
          throw StateError('nfc action unavailable');
        },
        openWirelessSettingsIntent: () async {
          throw StateError('wireless action unavailable');
        },
      );

      final opened = await launcher.openNfcSettings();

      expect(opened, isFalse);
    });
  });

  group('NoopNfcSystemSettingsLauncher', () {
    test('is always unsupported and returns false', () async {
      const launcher = NoopNfcSystemSettingsLauncher();

      expect(launcher.isSupported, isFalse);
      expect(await launcher.openNfcSettings(), isFalse);
    });
  });
}
