import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/features/restriction_lifecycle/model/restriction_session_log.dart';
import 'package:pauza/src/features/restriction_lifecycle/data/restriction_session_reducer.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

void main() {
  group('RestrictionSessionReducer', () {
    const reducer = RestrictionSessionReducer();

    test('START -> PAUSE -> RESUME -> END derives counters and end time', () {
      const sessionId = 's1';
      final now = _dt(10_000);

      final afterStart = reducer.reduce(
        event: _event(
          id: 'e1',
          sessionId: sessionId,
          action: RestrictionLifecycleAction.start,
          occurredAtEpochMs: 1_000,
        ),
        currentSession: null,
        nowUtc: now,
      );

      final afterPause = reducer.reduce(
        event: _event(
          id: 'e2',
          sessionId: sessionId,
          action: RestrictionLifecycleAction.pause,
          occurredAtEpochMs: 2_000,
        ),
        currentSession: afterStart,
        nowUtc: now.add(const Duration(milliseconds: 1)),
      );

      final afterResume = reducer.reduce(
        event: _event(
          id: 'e3',
          sessionId: sessionId,
          action: RestrictionLifecycleAction.resume,
          occurredAtEpochMs: 3_500,
        ),
        currentSession: afterPause,
        nowUtc: now.add(const Duration(milliseconds: 2)),
      );

      final afterEnd = reducer.reduce(
        event: _event(id: 'e4', sessionId: sessionId, action: RestrictionLifecycleAction.end, occurredAtEpochMs: 4_000),
        currentSession: afterResume,
        nowUtc: now.add(const Duration(milliseconds: 3)),
      );

      expect(afterEnd.pauseCount, 1);
      expect(afterEnd.totalPausedMs, 1_500);
      expect(afterEnd.endedAt, _dt(4_000));
      expect(afterEnd.lastPausedAt, isNull);
      expect(afterEnd.integrityStatus, SessionIntegrityStatus.ok);
    });

    test('END while paused closes pause window at end timestamp', () {
      const sessionId = 's2';
      final now = _dt(10_000);

      final afterStart = reducer.reduce(
        event: _event(
          id: 'e10',
          sessionId: sessionId,
          action: RestrictionLifecycleAction.start,
          occurredAtEpochMs: 1_000,
        ),
        currentSession: null,
        nowUtc: now,
      );

      final afterPause = reducer.reduce(
        event: _event(
          id: 'e11',
          sessionId: sessionId,
          action: RestrictionLifecycleAction.pause,
          occurredAtEpochMs: 2_000,
        ),
        currentSession: afterStart,
        nowUtc: now.add(const Duration(milliseconds: 1)),
      );

      final afterEnd = reducer.reduce(
        event: _event(
          id: 'e12',
          sessionId: sessionId,
          action: RestrictionLifecycleAction.end,
          occurredAtEpochMs: 5_000,
        ),
        currentSession: afterPause,
        nowUtc: now.add(const Duration(milliseconds: 2)),
      );

      expect(afterEnd.totalPausedMs, 3_000);
      expect(afterEnd.lastPausedAt, isNull);
      expect(afterEnd.endedAt, _dt(5_000));
    });

    test('PAUSE without START creates anomaly session and keeps event usable', () {
      final now = _dt(10_000);

      final state = reducer.reduce(
        event: _event(id: 'e20', sessionId: 's3', action: RestrictionLifecycleAction.pause, occurredAtEpochMs: 3_000),
        currentSession: null,
        nowUtc: now,
      );

      expect(state.integrityStatus, SessionIntegrityStatus.anomaly);
      expect(state.lastAnomalyReason, 'pause_without_start');
      expect(state.endedAt, isNull);
      expect(state.createdAt, now);
      expect(state.updatedAt, now);
    });

    test('duplicate START on same session marks anomaly', () {
      const sessionId = 's4';
      final now = _dt(10_000);

      final firstStart = reducer.reduce(
        event: _event(
          id: 'e30',
          sessionId: sessionId,
          action: RestrictionLifecycleAction.start,
          occurredAtEpochMs: 1_000,
        ),
        currentSession: null,
        nowUtc: now,
      );

      final duplicateStart = reducer.reduce(
        event: _event(
          id: 'e31',
          sessionId: sessionId,
          action: RestrictionLifecycleAction.start,
          occurredAtEpochMs: 1_200,
        ),
        currentSession: firstStart,
        nowUtc: now.add(const Duration(milliseconds: 1)),
      );

      expect(duplicateStart.integrityStatus, SessionIntegrityStatus.anomaly);
      expect(duplicateStart.lastAnomalyReason, 'start_when_session_active');
      expect(duplicateStart.createdAt, firstStart.createdAt);
      expect(duplicateStart.updatedAt, now.add(const Duration(milliseconds: 1)));
    });
  });
}

RestrictionLifecycleEvent _event({
  required String id,
  required String sessionId,
  required RestrictionLifecycleAction action,
  required int occurredAtEpochMs,
}) {
  return RestrictionLifecycleEvent(
    id: id,
    sessionId: sessionId,
    modeId: 'mode-1',
    action: action,
    source: RestrictionLifecycleSource.manual,
    reason: 'test',
    occurredAt: DateTime.fromMillisecondsSinceEpoch(occurredAtEpochMs, isUtc: true),
  );
}

DateTime _dt(int epochMs) {
  return DateTime.fromMillisecondsSinceEpoch(epochMs, isUtc: true);
}
