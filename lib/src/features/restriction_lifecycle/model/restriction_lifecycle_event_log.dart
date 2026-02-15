import 'package:flutter/foundation.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

@immutable
final class RestrictionLifecycleEventLog {
  const RestrictionLifecycleEventLog({
    required this.id,
    required this.sessionId,
    required this.modeId,
    required this.action,
    required this.source,
    required this.reason,
    required this.occurredAt,
    required this.createdAt,
  });

  final String id;
  final String sessionId;
  final String modeId;
  final RestrictionLifecycleAction action;
  final RestrictionLifecycleSource source;
  final String reason;
  final DateTime occurredAt;
  final DateTime createdAt;

  factory RestrictionLifecycleEventLog.fromDbRow(Map<String, Object?> row) {
    return RestrictionLifecycleEventLog(
      id: row['id'] as String,
      sessionId: row['session_id'] as String,
      modeId: row['mode_id'] as String,
      action: RestrictionLifecycleAction.fromWire(row['action'] as String),
      source: RestrictionLifecycleSource.fromWire(row['source'] as String),
      reason: row['reason'] as String,
      occurredAt: DateTime.fromMillisecondsSinceEpoch(
        row['occurred_at'] as int,
        isUtc: true,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        row['created_at'] as int,
        isUtc: true,
      ),
    );
  }

  @override
  String toString() =>
      'RestrictionLifecycleEventLog('
      'id: $id, '
      'sessionId: $sessionId, '
      'modeId: $modeId, '
      'action: $action, '
      'source: $source, '
      'reason: $reason, '
      'occurredAt: $occurredAt, '
      'createdAt: $createdAt'
      ')';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is RestrictionLifecycleEventLog &&
        other.id == id &&
        other.sessionId == sessionId &&
        other.modeId == modeId &&
        other.action == action &&
        other.source == source &&
        other.reason == reason &&
        other.occurredAt == occurredAt &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    modeId,
    action,
    source,
    reason,
    occurredAt,
    createdAt,
  );
}
