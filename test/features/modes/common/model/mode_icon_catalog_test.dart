import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/features/modes/common/model/mode_icon.dart';
import 'package:material_symbols_icons/symbols.dart';

void main() {
  group('ModeIconCatalog', () {
    test('normalizes null and invalid tokens to default', () {
      expect(
        ModeIconCatalog.normalizeToken(null),
        ModeIconCatalog.defaultToken,
      );
      expect(
        ModeIconCatalog.normalizeToken('ms:v1:not_exists'),
        ModeIconCatalog.defaultToken,
      );
      expect(
        ModeIconCatalog.normalizeToken('  '),
        ModeIconCatalog.defaultToken,
      );
    });

    test('resolves known token to icon', () {
      expect(ModeIcon.fromToken('ms:v1:timer').icon, Symbols.timer);
    });
  });
}
