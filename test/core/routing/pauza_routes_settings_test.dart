import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/core/routing/pauza_routes.dart';
import 'package:pauza/src/features/nfc_chip_config/widget/nfc_chip_conf_screen.dart';
import 'package:pauza/src/features/qr_code_config/widget/qr_code_conf_screen.dart';

void main() {
  group('settings routes', () {
    test('contains expected paths for config screens', () {
      expect(PauzaRoutes.nfcChipConfig.path, '/settings/nfc-chip-config');
      expect(PauzaRoutes.qrCodeConfig.path, '/settings/qr-code-config');
    });

    test('builds expected screens for config routes', () {
      final nfcScreen = PauzaRoutes.nfcChipConfig.builder(const <String, String>{}, const <String, String>{});
      final qrScreen = PauzaRoutes.qrCodeConfig.builder(const <String, String>{}, const <String, String>{});

      expect(nfcScreen, isA<NfcChipConfScreen>());
      expect(qrScreen, isA<QrCodeConfScreen>());
    });
  });
}
