import 'package:flutter/foundation.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

enum SessionIntegrityStatus {
  ok,
  anomaly;

  String get dbValue => switch (this) {
    SessionIntegrityStatus.ok => 'ok',
    SessionIntegrityStatus.anomaly => 'anomaly',
  };

  static SessionIntegrityStatus fromDbValue(String raw) {
    return switch (raw) {
      'ok' => SessionIntegrityStatus.ok,
      'anomaly' => SessionIntegrityStatus.anomaly,
      _ => SessionIntegrityStatus.anomaly,
    };
  }
}

@immutable
final class RestrictionSessionLog {
  const RestrictionSessionLog({
    required this.sessionId,
    required this.modeId,
    required this.source,
    required this.startedAt,
    required this.endedAt,
    required this.pauseCount,
    required this.totalPausedMs,
    required this.lastPausedAt,
    required this.integrityStatus,
    required this.lastAnomalyReason,
    required this.lastEventId,
    required this.createdAt,
    required this.updatedAt,
  });

  final String sessionId;
  final String modeId;
  final RestrictionLifecycleSource source;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int pauseCount;
  final int totalPausedMs;
  final DateTime? lastPausedAt;
  final SessionIntegrityStatus integrityStatus;
  final String? lastAnomalyReason;
  final String lastEventId;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory RestrictionSessionLog.fromDbRow(Map<String, Object?> row) {
    return RestrictionSessionLog(
      sessionId: row['session_id'] as String,
      modeId: row['mode_id'] as String,
      source: RestrictionLifecycleSource.fromWire(row['source'] as String),
      startedAt: DateTime.fromMillisecondsSinceEpoch(
        row['started_at'] as int,
        isUtc: true,
      ),
      endedAt: _readNullableUtcDateTime(row['ended_at']),
      pauseCount: row['pause_count'] as int,
      totalPausedMs: row['total_paused_ms'] as int,
      lastPausedAt: _readNullableUtcDateTime(row['last_paused_at']),
      integrityStatus: SessionIntegrityStatus.fromDbValue(
        row['integrity_status'] as String,
      ),
      lastAnomalyReason: row['last_anomaly_reason'] as String?,
      lastEventId: row['last_event_id'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        row['created_at'] as int,
        isUtc: true,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        row['updated_at'] as int,
        isUtc: true,
      ),
    );
  }

  RestrictionSessionLog copyWith({
    String? sessionId,
    String? modeId,
    RestrictionLifecycleSource? source,
    DateTime? startedAt,
    DateTime? endedAt,
    bool clearEndedAt = false,
    int? pauseCount,
    int? totalPausedMs,
    DateTime? lastPausedAt,
    bool clearLastPausedAt = false,
    SessionIntegrityStatus? integrityStatus,
    String? lastAnomalyReason,
    bool clearLastAnomalyReason = false,
    String? lastEventId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RestrictionSessionLog(
      sessionId: sessionId ?? this.sessionId,
      modeId: modeId ?? this.modeId,
      source: source ?? this.source,
      startedAt: startedAt ?? this.startedAt,
      endedAt: clearEndedAt ? null : (endedAt ?? this.endedAt),
      pauseCount: pauseCount ?? this.pauseCount,
      totalPausedMs: totalPausedMs ?? this.totalPausedMs,
      lastPausedAt: clearLastPausedAt
          ? null
          : (lastPausedAt ?? this.lastPausedAt),
      integrityStatus: integrityStatus ?? this.integrityStatus,
      lastAnomalyReason: clearLastAnomalyReason
          ? null
          : (lastAnomalyReason ?? this.lastAnomalyReason),
      lastEventId: lastEventId ?? this.lastEventId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  List<Object?> toUpsertArgs() {
    return <Object?>[
      sessionId,
      modeId,
      source.wireValue,
      startedAt.toUtc().millisecondsSinceEpoch,
      endedAt?.toUtc().millisecondsSinceEpoch,
      pauseCount,
      totalPausedMs,
      lastPausedAt?.toUtc().millisecondsSinceEpoch,
      integrityStatus.dbValue,
      lastAnomalyReason,
      lastEventId,
      createdAt.toUtc().millisecondsSinceEpoch,
      updatedAt.toUtc().millisecondsSinceEpoch,
    ];
  }

  @override
  String toString() =>
      'RestrictionSessionLog('
      'sessionId: $sessionId, '
      'modeId: $modeId, '
      'source: $source, '
      'startedAt: $startedAt, '
      'endedAt: $endedAt, '
      'pauseCount: $pauseCount, '
      'totalPausedMs: $totalPausedMs, '
      'lastPausedAt: $lastPausedAt, '
      'integrityStatus: $integrityStatus, '
      'lastAnomalyReason: $lastAnomalyReason, '
      'lastEventId: $lastEventId, '
      'createdAt: $createdAt, '
      'updatedAt: $updatedAt'
      ')';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is RestrictionSessionLog &&
        other.sessionId == sessionId &&
        other.modeId == modeId &&
        other.source == source &&
        other.startedAt == startedAt &&
        other.endedAt == endedAt &&
        other.pauseCount == pauseCount &&
        other.totalPausedMs == totalPausedMs &&
        other.lastPausedAt == lastPausedAt &&
        other.integrityStatus == integrityStatus &&
        other.lastAnomalyReason == lastAnomalyReason &&
        other.lastEventId == lastEventId &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
    sessionId,
    modeId,
    source,
    startedAt,
    endedAt,
    pauseCount,
    totalPausedMs,
    lastPausedAt,
    integrityStatus,
    lastAnomalyReason,
    lastEventId,
    createdAt,
    updatedAt,
  );

  static DateTime? _readNullableUtcDateTime(Object? value) {
    if (value case final int epochMs) {
      return DateTime.fromMillisecondsSinceEpoch(epochMs, isUtc: true);
    }
    return null;
  }
}
