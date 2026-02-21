import 'package:flutter/foundation.dart';
import 'package:pauza/src/features/qr_code_config/model/qr_unlock_token.dart';

@immutable
final class QrLinkedCode {
  const QrLinkedCode({
    required this.id,
    required this.scanValue,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final QrUnlockToken scanValue;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory QrLinkedCode.fromDbRow(Map<String, Object?> row) {
    return QrLinkedCode(
      id: row['id'] as String,
      scanValue: QrUnlockToken.parse(row['scan_value'] as String),
      name: row['name'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int, isUtc: true),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(row['updated_at'] as int, isUtc: true),
    );
  }

  @override
  String toString() {
    return 'QrLinkedCode('
        'id: $id, '
        'scanValue: $scanValue, '
        'name: $name, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is QrLinkedCode &&
        other.id == id &&
        other.scanValue == scanValue &&
        other.name == name &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(id, scanValue, name, createdAt, updatedAt);
}
