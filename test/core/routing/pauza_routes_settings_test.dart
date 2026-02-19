import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/core/routing/pauza_routes.dart';

void main() {
  group('settings routes', () {
    test('contains expected paths for config screens', () {
      expect(PauzaRoutes.nfcChipConfig.path, '/settings/nfc-chip-config');
      expect(PauzaRoutes.qrCodeConfig.path, '/settings/qr-code-config');
    });
  });
}
