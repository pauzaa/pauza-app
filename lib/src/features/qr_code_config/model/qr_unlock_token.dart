import 'package:uuid/uuid.dart';

extension type const QrUnlockToken._(String value) {
  static const String _prefix = 'pauza:qr:v1:';
  static final RegExp _uuidV4Pattern = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$');

  factory QrUnlockToken.parse(String raw) {
    final normalized = raw.trim().toLowerCase();
    if (!normalized.startsWith(_prefix)) {
      throw ArgumentError.value(raw, 'raw', 'Invalid QR unlock token prefix');
    }

    final uuidPart = normalized.substring(_prefix.length);
    if (!_uuidV4Pattern.hasMatch(uuidPart)) {
      throw ArgumentError.value(raw, 'raw', 'Invalid QR unlock token UUID');
    }

    return QrUnlockToken._(normalized);
  }

  static QrUnlockToken generate({required Uuid uuid}) {
    final uuidValue = uuid.v4().toLowerCase();
    return QrUnlockToken.parse('$_prefix$uuidValue');
  }

  static QrUnlockToken? tryParse(String raw) {
    try {
      return QrUnlockToken.parse(raw);
    } on Object {
      return null;
    }
  }

  String get normalized => value;
}
