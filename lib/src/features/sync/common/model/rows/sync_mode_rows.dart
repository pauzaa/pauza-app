import 'package:flutter/foundation.dart';

@immutable
final class SyncModeRow {
  const SyncModeRow({
    required this.id,
    required this.title,
    required this.textOnScreen,
    required this.description,
    required this.allowedPausesCount,
    required this.minimumDurationMs,
    required this.endingPausingScenario,
    required this.iconToken,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String textOnScreen;
  final String? description;
  final int allowedPausesCount;
  final int? minimumDurationMs;
  final String endingPausingScenario;
  final String iconToken;
  final int createdAt;
  final int updatedAt;

  factory SyncModeRow.fromMap(Map<String, Object?> map) {
    return SyncModeRow(
      id: map['id'] as String,
      title: map['title'] as String,
      textOnScreen: map['text_on_screen'] as String,
      description: map['description'] as String?,
      allowedPausesCount: map['allowed_pauses_count'] as int,
      minimumDurationMs: map['minimum_duration_ms'] as int?,
      endingPausingScenario: map['ending_pausing_scenario'] as String,
      iconToken: map['icon_token'] as String,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'title': title,
      'text_on_screen': textOnScreen,
      'description': description,
      'allowed_pauses_count': allowedPausesCount,
      'minimum_duration_ms': minimumDurationMs,
      'ending_pausing_scenario': endingPausingScenario,
      'icon_token': iconToken,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  String toString() => 'SyncModeRow(id: $id, title: $title, updatedAt: $updatedAt)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncModeRow &&
          other.id == id &&
          other.title == title &&
          other.textOnScreen == textOnScreen &&
          other.description == description &&
          other.allowedPausesCount == allowedPausesCount &&
          other.minimumDurationMs == minimumDurationMs &&
          other.endingPausingScenario == endingPausingScenario &&
          other.iconToken == iconToken &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(
    id,
    title,
    textOnScreen,
    description,
    allowedPausesCount,
    minimumDurationMs,
    endingPausingScenario,
    iconToken,
    createdAt,
    updatedAt,
  );
}

@immutable
final class SyncModeBlockedAppRow {
  const SyncModeBlockedAppRow({
    required this.modeId,
    required this.platform,
    required this.appIdentifier,
    required this.createdAt,
    required this.updatedAt,
  });

  final String modeId;
  final String platform;
  final String appIdentifier;
  final int createdAt;
  final int updatedAt;

  factory SyncModeBlockedAppRow.fromMap(Map<String, Object?> map) {
    return SyncModeBlockedAppRow(
      modeId: map['mode_id'] as String,
      platform: map['platform'] as String,
      appIdentifier: map['app_identifier'] as String,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'mode_id': modeId,
      'platform': platform,
      'app_identifier': appIdentifier,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  String toString() =>
      'SyncModeBlockedAppRow(modeId: $modeId, platform: $platform, '
      'appIdentifier: $appIdentifier)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncModeBlockedAppRow &&
          other.modeId == modeId &&
          other.platform == platform &&
          other.appIdentifier == appIdentifier &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(modeId, platform, appIdentifier, createdAt, updatedAt);
}

@immutable
final class SyncModeBlockedAppKey {
  const SyncModeBlockedAppKey({required this.modeId, required this.platform, required this.appIdentifier});

  final String modeId;
  final String platform;
  final String appIdentifier;

  factory SyncModeBlockedAppKey.fromJson(Map<String, Object?> json) {
    return SyncModeBlockedAppKey(
      modeId: json['mode_id'] as String,
      platform: json['platform'] as String,
      appIdentifier: json['app_identifier'] as String,
    );
  }

  Map<String, String> toJson() {
    return <String, String>{'mode_id': modeId, 'platform': platform, 'app_identifier': appIdentifier};
  }

  @override
  String toString() =>
      'SyncModeBlockedAppKey(modeId: $modeId, platform: $platform, '
      'appIdentifier: $appIdentifier)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncModeBlockedAppKey &&
          other.modeId == modeId &&
          other.platform == platform &&
          other.appIdentifier == appIdentifier;

  @override
  int get hashCode => Object.hash(modeId, platform, appIdentifier);
}

@immutable
final class SyncScheduleRow {
  const SyncScheduleRow({
    required this.id,
    required this.modeId,
    required this.days,
    required this.startMinute,
    required this.endMinute,
    required this.enabled,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String modeId;
  final String days;
  final int startMinute;
  final int endMinute;
  final int enabled;
  final int createdAt;
  final int updatedAt;

  factory SyncScheduleRow.fromMap(Map<String, Object?> map) {
    return SyncScheduleRow(
      id: map['id'] as String,
      modeId: map['mode_id'] as String,
      days: map['days'] as String,
      startMinute: map['start_minute'] as int,
      endMinute: map['end_minute'] as int,
      enabled: map['enabled'] as int,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'mode_id': modeId,
      'days': days,
      'start_minute': startMinute,
      'end_minute': endMinute,
      'enabled': enabled,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  String toString() => 'SyncScheduleRow(id: $id, modeId: $modeId, days: $days)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncScheduleRow &&
          other.id == id &&
          other.modeId == modeId &&
          other.days == days &&
          other.startMinute == startMinute &&
          other.endMinute == endMinute &&
          other.enabled == enabled &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(id, modeId, days, startMinute, endMinute, enabled, createdAt, updatedAt);
}
