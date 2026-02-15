enum NfcTagTech {
  ndef(platformKey: 'ndef'),
  nfcA(platformKey: 'nfca'),
  nfcB(platformKey: 'nfcb'),
  nfcF(platformKey: 'nfcf'),
  nfcV(platformKey: 'nfcv'),
  isoDep(platformKey: 'isodep'),
  iso7816(platformKey: 'iso7816'),
  iso15693(platformKey: 'iso15693'),
  mifareClassic(platformKey: 'mifareclassic'),
  mifareUltralight(platformKey: 'mifareultralight'),
  felica(platformKey: 'felica'),
  unknown(platformKey: 'unknown');

  const NfcTagTech({required this.platformKey});

  final String platformKey;

  static NfcTagTech fromPlatformKey(String key) {
    final normalized = key.toLowerCase();
    for (final value in NfcTagTech.values) {
      if (value.platformKey == normalized) {
        return value;
      }
    }
    return NfcTagTech.unknown;
  }
}
