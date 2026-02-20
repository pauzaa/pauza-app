import 'package:pauza/src/features/restriction_lifecycle/model/restriction_session_log.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

final class RestrictionSessionReducer {
  const RestrictionSessionReducer();

  RestrictionSessionLog reduce({
    required RestrictionLifecycleEvent event,
    required RestrictionSessionLog? currentSession,
    required DateTime nowUtc,
  }) {
    final occurredAt = event.occurredAt.toUtc();
    final now = nowUtc.toUtc();

    if (currentSession == null) {
      return _reduceWithoutSession(event: event, occurredAt: occurredAt, now: now);
    }

    return _reduceWithSession(event: event, session: currentSession, occurredAt: occurredAt, now: now);
  }

  RestrictionSessionLog _reduceWithoutSession({
    required RestrictionLifecycleEvent event,
    required DateTime occurredAt,
    required DateTime now,
  }) {
    final action = event.action;
    if (action == RestrictionLifecycleAction.start) {
      return RestrictionSessionLog(
        sessionId: event.sessionId,
        modeId: event.modeId,
        source: event.source,
        startedAt: occurredAt,
        endedAt: null,
        pauseCount: 0,
        totalPausedMs: 0,
        lastPausedAt: null,
        integrityStatus: SessionIntegrityStatus.ok,
        lastAnomalyReason: null,
        lastEventId: event.id,
        createdAt: now,
        updatedAt: now,
      );
    }

    final reason = switch (action) {
      RestrictionLifecycleAction.pause => 'pause_without_start',
      RestrictionLifecycleAction.resume => 'resume_without_start',
      RestrictionLifecycleAction.end => 'end_without_start',
      RestrictionLifecycleAction.start => null,
    };

    return RestrictionSessionLog(
      sessionId: event.sessionId,
      modeId: event.modeId,
      source: event.source,
      startedAt: occurredAt,
      endedAt: action == RestrictionLifecycleAction.end ? occurredAt : null,
      pauseCount: 0,
      totalPausedMs: 0,
      lastPausedAt: null,
      integrityStatus: SessionIntegrityStatus.anomaly,
      lastAnomalyReason: reason,
      lastEventId: event.id,
      createdAt: now,
      updatedAt: now,
    );
  }

  RestrictionSessionLog _reduceWithSession({
    required RestrictionLifecycleEvent event,
    required RestrictionSessionLog session,
    required DateTime occurredAt,
    required DateTime now,
  }) {
    return switch (event.action) {
      RestrictionLifecycleAction.start => _reduceStart(event: event, session: session, now: now),
      RestrictionLifecycleAction.pause => _reducePause(
        event: event,
        session: session,
        occurredAt: occurredAt,
        now: now,
      ),
      RestrictionLifecycleAction.resume => _reduceResume(
        event: event,
        session: session,
        occurredAt: occurredAt,
        now: now,
      ),
      RestrictionLifecycleAction.end => _reduceEnd(event: event, session: session, occurredAt: occurredAt, now: now),
    };
  }

  RestrictionSessionLog _reduceStart({
    required RestrictionLifecycleEvent event,
    required RestrictionSessionLog session,
    required DateTime now,
  }) {
    final reason = session.endedAt == null ? 'start_when_session_active' : 'duplicate_start_for_session';

    return session.copyWith(
      modeId: event.modeId,
      source: event.source,
      integrityStatus: SessionIntegrityStatus.anomaly,
      lastAnomalyReason: reason,
      lastEventId: event.id,
      updatedAt: now,
    );
  }

  RestrictionSessionLog _reducePause({
    required RestrictionLifecycleEvent event,
    required RestrictionSessionLog session,
    required DateTime occurredAt,
    required DateTime now,
  }) {
    if (session.endedAt != null) {
      return session.copyWith(
        integrityStatus: SessionIntegrityStatus.anomaly,
        lastAnomalyReason: 'pause_after_end',
        lastEventId: event.id,
        updatedAt: now,
      );
    }

    if (session.lastPausedAt != null) {
      return session.copyWith(
        integrityStatus: SessionIntegrityStatus.anomaly,
        lastAnomalyReason: 'pause_when_already_paused',
        lastEventId: event.id,
        updatedAt: now,
      );
    }

    return session.copyWith(
      pauseCount: session.pauseCount + 1,
      lastPausedAt: occurredAt,
      lastEventId: event.id,
      updatedAt: now,
    );
  }

  RestrictionSessionLog _reduceResume({
    required RestrictionLifecycleEvent event,
    required RestrictionSessionLog session,
    required DateTime occurredAt,
    required DateTime now,
  }) {
    if (session.endedAt != null) {
      return session.copyWith(
        integrityStatus: SessionIntegrityStatus.anomaly,
        lastAnomalyReason: 'resume_after_end',
        lastEventId: event.id,
        updatedAt: now,
      );
    }

    final pauseStartedAt = session.lastPausedAt;
    if (pauseStartedAt == null) {
      return session.copyWith(
        clearLastPausedAt: true,
        integrityStatus: SessionIntegrityStatus.anomaly,
        lastAnomalyReason: 'resume_without_pause',
        lastEventId: event.id,
        updatedAt: now,
      );
    }

    final occurredEpochMs = occurredAt.toUtc().millisecondsSinceEpoch;
    final pauseStartedEpochMs = pauseStartedAt.toUtc().millisecondsSinceEpoch;
    final pauseDurationMs = occurredEpochMs >= pauseStartedEpochMs ? occurredEpochMs - pauseStartedEpochMs : 0;

    return session.copyWith(
      totalPausedMs: session.totalPausedMs + pauseDurationMs,
      clearLastPausedAt: true,
      lastEventId: event.id,
      updatedAt: now,
    );
  }

  RestrictionSessionLog _reduceEnd({
    required RestrictionLifecycleEvent event,
    required RestrictionSessionLog session,
    required DateTime occurredAt,
    required DateTime now,
  }) {
    if (session.endedAt != null) {
      return session.copyWith(
        integrityStatus: SessionIntegrityStatus.anomaly,
        lastAnomalyReason: 'duplicate_end_for_session',
        lastEventId: event.id,
        updatedAt: now,
      );
    }

    final pauseStartedAt = session.lastPausedAt;
    final pauseDurationMs =
        pauseStartedAt != null &&
            occurredAt.toUtc().millisecondsSinceEpoch >= pauseStartedAt.toUtc().millisecondsSinceEpoch
        ? occurredAt.toUtc().millisecondsSinceEpoch - pauseStartedAt.toUtc().millisecondsSinceEpoch
        : 0;

    return session.copyWith(
      endedAt: occurredAt,
      totalPausedMs: session.totalPausedMs + pauseDurationMs,
      clearLastPausedAt: true,
      lastEventId: event.id,
      updatedAt: now,
    );
  }
}
