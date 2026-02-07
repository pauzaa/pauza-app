import 'package:flutter/foundation.dart';

@immutable
class Mode {
  const Mode({
    required this.id,
    required this.title,
    required this.textOnScreen,
    required this.description,
    required this.allowedPausesCount,
    required this.isEnabled,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Mode.fromMap(Map<String, Object?> row) => Mode(
    id: row['id'].toString(),
    title: row['title'].toString(),
    textOnScreen: row['text_on_screen'].toString(),
    description: row['description'].toString(),
    allowedPausesCount: int.tryParse(row['allowed_pauses_count'].toString()) ?? 0,
    isEnabled: int.tryParse(row['is_enabled'].toString()) == 1,
    createdAt: DateTime.fromMillisecondsSinceEpoch(int.tryParse(row['created_at'].toString()) ?? 0),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(int.tryParse(row['updated_at'].toString()) ?? 0),
  );

  final String id;
  final String title;
  final String textOnScreen;
  final String? description;
  final int allowedPausesCount;
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  Mode copyWith({
    String? title,
    String? textOnScreen,
    String? description,
    int? allowedPausesCount,
    bool? isEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Mode(
    id: id,
    title: title ?? this.title,
    textOnScreen: textOnScreen ?? this.textOnScreen,
    description: description ?? this.description,
    allowedPausesCount: allowedPausesCount ?? this.allowedPausesCount,
    isEnabled: isEnabled ?? this.isEnabled,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  String toString() =>
      'Mode(id: $id, title: $title, textOnScreen: $textOnScreen, '
      'description: $description, allowedPausesCount: $allowedPausesCount, '
      'isEnabled: $isEnabled, createdAt: $createdAt, updatedAt: $updatedAt)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Mode &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          textOnScreen == other.textOnScreen &&
          description == other.description &&
          allowedPausesCount == other.allowedPausesCount &&
          isEnabled == other.isEnabled &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hash(
    id,
    title,
    textOnScreen,
    description,
    allowedPausesCount,
    isEnabled,
    createdAt,
    updatedAt,
  );
}
