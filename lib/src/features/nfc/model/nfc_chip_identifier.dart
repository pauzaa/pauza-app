extension type const NfcChipIdentifier._(String value) implements String {
  static final RegExp _hexPattern = RegExp(r'^[0-9a-f]+$');

  factory NfcChipIdentifier.parse(String raw) {
    final normalized = raw.trim().toLowerCase();
    if (normalized.isEmpty) {
      throw ArgumentError.value(raw, 'raw', 'NFC chip identifier must not be empty');
    }
    if (!_hexPattern.hasMatch(normalized)) {
      throw ArgumentError.value(raw, 'raw', 'NFC chip identifier must be a valid lowercase hex string');
    }
    if (normalized.length.isOdd) {
      throw ArgumentError.value(raw, 'raw', 'NFC chip identifier must have an even number of hex characters');
    }
    return NfcChipIdentifier._(normalized);
  }

  static NfcChipIdentifier? tryParse(String raw) {
    try {
      return NfcChipIdentifier.parse(raw);
    } on Object {
      return null;
    }
  }

  String get normalized => value;
}
