import 'package:flutter/foundation.dart';

@immutable
final class NfcLinkedChip {
  const NfcLinkedChip({
    required this.id,
    required this.chipIdentifier,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String chipIdentifier;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory NfcLinkedChip.fromDbRow(Map<String, Object?> row) {
    return NfcLinkedChip(
      id: row['id'] as String,
      chipIdentifier: row['chip_identifier'] as String,
      name: row['name'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int, isUtc: true),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(row['updated_at'] as int, isUtc: true),
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'chip_identifier': chipIdentifier,
      'name': name,
      'created_at': createdAt.toUtc().millisecondsSinceEpoch,
      'updated_at': updatedAt.toUtc().millisecondsSinceEpoch,
    };
  }

  @override
  String toString() {
    return 'NfcLinkedChip('
        'id: $id, '
        'chipIdentifier: $chipIdentifier, '
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

    return other is NfcLinkedChip &&
        other.id == id &&
        other.chipIdentifier == chipIdentifier &&
        other.name == name &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(id, chipIdentifier, name, createdAt, updatedAt);
}
