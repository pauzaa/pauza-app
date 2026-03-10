import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:pauza/src/features/nfc/model/nfc_chip_identifier.dart';

import 'fixtures.dart';

void registerTestFallbackValues() {
  registerFallbackValue(Duration.zero);
  registerFallbackValue((() {}) as void Function());
  registerFallbackValue(Uint8List(0));
  registerFallbackValue(makeCachedUserProfile());
  registerFallbackValue(makeModeUpsertDto());
  registerFallbackValue(NfcChipIdentifier.parse('0000'));
}
