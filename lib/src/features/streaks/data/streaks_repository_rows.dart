part of 'streaks_repository.dart';

final class _RollupStateRow {
  const _RollupStateRow({
    required this.cursorUpdatedAt,
    required this.cursorSessionId,
  });

  factory _RollupStateRow.fromJson(Map<String, Object?> row) {
    return _RollupStateRow(
      cursorUpdatedAt: row['session_cursor_updated_at'].intOrZero,
      cursorSessionId: row['session_cursor_id'] as String,
    );
  }

  final int cursorUpdatedAt;
  final String cursorSessionId;
}

final class _SessionForRefresh {
  const _SessionForRefresh({
    required this.sessionId,
    required this.endedAtEpochMs,
    required this.integrityStatus,
    required this.updatedAtEpochMs,
  });

  factory _SessionForRefresh.fromJson(Map<String, Object?> row) {
    return _SessionForRefresh(
      sessionId: row['session_id'] as String,
      endedAtEpochMs: row['ended_at'] as int?,
      integrityStatus: row['integrity_status'] as String,
      updatedAtEpochMs: row['updated_at'].intOrZero,
    );
  }

  final String sessionId;
  final int? endedAtEpochMs;
  final String integrityStatus;
  final int updatedAtEpochMs;
}

final class _LifecycleEventPointDto {
  const _LifecycleEventPointDto({
    required this.action,
    required this.occurredAtUtc,
  });

  factory _LifecycleEventPointDto.fromJson(Map<String, Object?> row) {
    return _LifecycleEventPointDto(
      action: RestrictionLifecycleAction.fromWire(row['action'] as String),
      occurredAtUtc: DateTime.fromMillisecondsSinceEpoch(
        row['occurred_at'].intOrZero,
        isUtc: true,
      ),
    );
  }

  final RestrictionLifecycleAction action;
  final DateTime occurredAtUtc;

  StreakLifecycleEventPoint toDomain() {
    return StreakLifecycleEventPoint(
      action: action,
      occurredAtUtc: occurredAtUtc,
    );
  }
}

final class _SessionDayEffectiveMsDto {
  const _SessionDayEffectiveMsDto({
    required this.localDay,
    required this.effectiveMs,
  });

  factory _SessionDayEffectiveMsDto.fromEntry(
    MapEntry<LocalDayKey, int> entry,
  ) {
    return _SessionDayEffectiveMsDto(
      localDay: entry.key,
      effectiveMs: entry.value,
    );
  }

  final LocalDayKey localDay;
  final int effectiveMs;

  static List<_SessionDayEffectiveMsDto> splitIntervalsByLocalDay({
    required IList<UtcInterval> intervals,
  }) {
    final byDay = <LocalDayKey, int>{};

    for (final interval in intervals) {
      var cursor = interval.startUtc;

      while (cursor.isBefore(interval.endUtc)) {
        final localCursor = cursor.toLocal();
        final nextLocalDayStart = DateTime(
          localCursor.year,
          localCursor.month,
          localCursor.day + 1,
        );
        final nextBoundaryUtc = nextLocalDayStart.toUtc();
        final segmentEnd = nextBoundaryUtc.isBefore(interval.endUtc)
            ? nextBoundaryUtc
            : interval.endUtc;

        if (!segmentEnd.isAfter(cursor)) {
          break;
        }

        final dayKey = LocalDayKey.fromDateTime(localCursor);
        byDay[dayKey] =
            (byDay[dayKey] ?? 0) + segmentEnd.difference(cursor).inMilliseconds;
        cursor = segmentEnd;
      }
    }

    return byDay.entries
        .map(_SessionDayEffectiveMsDto.fromEntry)
        .toList(growable: false);
  }
}
