import 'package:flutter/foundation.dart';

@immutable
final class SyncStreakRollupRow {
  const SyncStreakRollupRow({
    required this.sessionId,
    required this.localDay,
    required this.effectiveMs,
    required this.updatedAt,
  });

  final String sessionId;
  final String localDay;
  final int effectiveMs;
  final int updatedAt;

  factory SyncStreakRollupRow.fromMap(Map<String, Object?> map) {
    return SyncStreakRollupRow(
      sessionId: map['session_id'] as String,
      localDay: map['local_day'] as String,
      effectiveMs: map['effective_ms'] as int,
      updatedAt: map['updated_at'] as int,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'session_id': sessionId,
      'local_day': localDay,
      'effective_ms': effectiveMs,
      'updated_at': updatedAt,
    };
  }

  @override
  String toString() =>
      'SyncStreakRollupRow(sessionId: $sessionId, localDay: $localDay, '
      'effectiveMs: $effectiveMs)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncStreakRollupRow &&
          other.sessionId == sessionId &&
          other.localDay == localDay &&
          other.effectiveMs == effectiveMs &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode =>
      Object.hash(sessionId, localDay, effectiveMs, updatedAt);
}

@immutable
final class SyncStreakRollupKey {
  const SyncStreakRollupKey({
    required this.sessionId,
    required this.localDay,
  });

  final String sessionId;
  final String localDay;

  factory SyncStreakRollupKey.fromJson(Map<String, Object?> json) {
    return SyncStreakRollupKey(
      sessionId: json['session_id'] as String,
      localDay: json['local_day'] as String,
    );
  }

  Map<String, String> toJson() {
    return <String, String>{
      'session_id': sessionId,
      'local_day': localDay,
    };
  }

  @override
  String toString() =>
      'SyncStreakRollupKey(sessionId: $sessionId, localDay: $localDay)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncStreakRollupKey &&
          other.sessionId == sessionId &&
          other.localDay == localDay;

  @override
  int get hashCode => Object.hash(sessionId, localDay);
}

@immutable
final class SyncStreakAggregateRow {
  const SyncStreakAggregateRow({
    required this.localDay,
    required this.effectiveMs,
    required this.qualified,
    required this.sourceSessionCount,
    required this.updatedAt,
  });

  final String localDay;
  final int effectiveMs;
  final int qualified;
  final int sourceSessionCount;
  final int updatedAt;

  factory SyncStreakAggregateRow.fromMap(Map<String, Object?> map) {
    return SyncStreakAggregateRow(
      localDay: map['local_day'] as String,
      effectiveMs: map['effective_ms'] as int,
      qualified: map['qualified'] as int,
      sourceSessionCount: map['source_session_count'] as int,
      updatedAt: map['updated_at'] as int,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'local_day': localDay,
      'effective_ms': effectiveMs,
      'qualified': qualified,
      'source_session_count': sourceSessionCount,
      'updated_at': updatedAt,
    };
  }

  @override
  String toString() =>
      'SyncStreakAggregateRow(localDay: $localDay, effectiveMs: $effectiveMs, '
      'qualified: $qualified)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncStreakAggregateRow &&
          other.localDay == localDay &&
          other.effectiveMs == effectiveMs &&
          other.qualified == qualified &&
          other.sourceSessionCount == sourceSessionCount &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode =>
      Object.hash(localDay, effectiveMs, qualified, sourceSessionCount, updatedAt);
}
