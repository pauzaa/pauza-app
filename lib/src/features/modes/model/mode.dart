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

  final String id;
  final String title;
  final String textOnScreen;
  final String? description;
  final int allowedPausesCount;
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

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
