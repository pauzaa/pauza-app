import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/features/home/data/pauza_blocking_repository.dart';
import 'package:pauza/src/features/home/model/blocking_action_error.dart';
import 'package:pauza/src/features/modes/common/model/mode_ending_pausing_scenario.dart';
import 'package:pauza/src/features/modes/common/model/mode.dart';
import 'package:pauza/src/features/modes/common/model/mode_icon.dart';
import 'package:pauza/src/features/restriction_lifecycle/data/restriction_lifecycle_repository.dart';
import 'package:pauza/src/features/restriction_lifecycle/model/restriction_lifecycle_event_log.dart';
import 'package:pauza/src/features/restriction_lifecycle/model/restriction_session_log.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

void main() {
  group('PauzaBlockingRepository', () {
    test('emits lifecycle actions for start, pause, resume, and stop', () async {
      final restrictions = _FakeAppRestrictionManager();
      final lifecycleRepository = _FakeRestrictionLifecycleRepository();
      final repository = PauzaBlockingRepository(
        restrictions: restrictions,
        restrictionLifecycleRepository: lifecycleRepository,
      );
      final emittedActions = <RestrictionLifecycleAction>[];
      final subscription = repository.lifecycleActions.listen(emittedActions.add);
      final restrictionState = _restrictionStateWithSession(
        source: RestrictionLifecycleSource.manual,
        startedAt: DateTime.now().toUtc().subtract(const Duration(minutes: 10)),
      );

      await repository.startBlocking(mode: _mode, shield: null);
      await repository.pauseBlocking(const Duration(minutes: 1), mode: _mode, restrictionState: restrictionState);
      await repository.resumeBlocking();
      await repository.stopBlocking(mode: _mode, restrictionState: restrictionState);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(emittedActions, <RestrictionLifecycleAction>[
        RestrictionLifecycleAction.start,
        RestrictionLifecycleAction.pause,
        RestrictionLifecycleAction.resume,
        RestrictionLifecycleAction.end,
      ]);

      await subscription.cancel();
      repository.dispose();
    });

    test('does not emit lifecycle action when only sync is called', () async {
      final restrictions = _FakeAppRestrictionManager();
      final lifecycleRepository = _FakeRestrictionLifecycleRepository();
      final repository = PauzaBlockingRepository(
        restrictions: restrictions,
        restrictionLifecycleRepository: lifecycleRepository,
      );
      final emittedActions = <RestrictionLifecycleAction>[];
      final subscription = repository.lifecycleActions.listen(emittedActions.add);

      await repository.syncRestrictionLifecycleEvents();
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(emittedActions, isEmpty);

      await subscription.cancel();
      repository.dispose();
    });

    test('pause accepted below limit', () async {
      final restrictions = _FakeAppRestrictionManager();
      final lifecycleRepository = _FakeRestrictionLifecycleRepository();
      final repository = PauzaBlockingRepository(
        restrictions: restrictions,
        restrictionLifecycleRepository: lifecycleRepository,
      );
      final restrictionState = _restrictionStateWithSession(
        source: RestrictionLifecycleSource.manual,
        startedAt: DateTime.now().toUtc().subtract(const Duration(minutes: 10)),
      );

      await repository.pauseBlocking(const Duration(minutes: 1), mode: _mode, restrictionState: restrictionState);

      expect(restrictions.pauseCalls, 1);
      repository.dispose();
    });

    test('pause rejected at or above pause limit', () async {
      final restrictions = _FakeAppRestrictionManager();
      final lifecycleRepository = _FakeRestrictionLifecycleRepository();
      final repository = PauzaBlockingRepository(
        restrictions: restrictions,
        restrictionLifecycleRepository: lifecycleRepository,
      );
      final restrictionState = _restrictionStateWithSession(
        source: RestrictionLifecycleSource.manual,
        startedAt: DateTime.now().toUtc().subtract(const Duration(minutes: 10)),
        pauseEventsCount: 1,
      );

      await expectLater(
        () => repository.pauseBlocking(const Duration(minutes: 1), mode: _mode, restrictionState: restrictionState),
        throwsA(isA<PauseLimitReachedError>()),
      );
      expect(restrictions.pauseCalls, 0);
      repository.dispose();
    });

    test('end rejected before minimum duration', () async {
      final restrictions = _FakeAppRestrictionManager();
      final lifecycleRepository = _FakeRestrictionLifecycleRepository();
      final repository = PauzaBlockingRepository(
        restrictions: restrictions,
        restrictionLifecycleRepository: lifecycleRepository,
      );
      final mode = _mode.copyWith(minimumDuration: const Duration(minutes: 30));
      final restrictionState = _restrictionStateWithSession(
        source: RestrictionLifecycleSource.manual,
        startedAt: DateTime.now().toUtc().subtract(const Duration(minutes: 5)),
      );

      await expectLater(
        () => repository.stopBlocking(mode: mode, restrictionState: restrictionState),
        throwsA(
          isA<MinimumDurationNotReachedError>().having(
            (error) => error.remaining,
            'remaining',
            greaterThan(Duration.zero),
          ),
        ),
      );
      expect(restrictions.endCalls, 0);
      repository.dispose();
    });

    test('pause is not blocked by minimum duration', () async {
      final restrictions = _FakeAppRestrictionManager();
      final lifecycleRepository = _FakeRestrictionLifecycleRepository();
      final repository = PauzaBlockingRepository(
        restrictions: restrictions,
        restrictionLifecycleRepository: lifecycleRepository,
      );
      final mode = _mode.copyWith(minimumDuration: const Duration(minutes: 30));
      final restrictionState = _restrictionStateWithSession(
        source: RestrictionLifecycleSource.manual,
        startedAt: DateTime.now().toUtc().subtract(const Duration(minutes: 5)),
      );

      await repository.pauseBlocking(const Duration(minutes: 1), mode: mode, restrictionState: restrictionState);

      expect(restrictions.pauseCalls, 1);
      repository.dispose();
    });

    test('end accepted when minimum duration reached', () async {
      final restrictions = _FakeAppRestrictionManager();
      final lifecycleRepository = _FakeRestrictionLifecycleRepository();
      final repository = PauzaBlockingRepository(
        restrictions: restrictions,
        restrictionLifecycleRepository: lifecycleRepository,
      );
      final mode = _mode.copyWith(minimumDuration: const Duration(minutes: 10));
      final restrictionState = _restrictionStateWithSession(
        source: RestrictionLifecycleSource.manual,
        startedAt: DateTime.now().toUtc().subtract(const Duration(minutes: 11)),
      );

      await repository.stopBlocking(mode: mode, restrictionState: restrictionState);

      expect(restrictions.endCalls, 1);
      repository.dispose();
    });

    test('schedule source enforces rules same as manual source', () async {
      final restrictions = _FakeAppRestrictionManager();
      final lifecycleRepository = _FakeRestrictionLifecycleRepository();
      final repository = PauzaBlockingRepository(
        restrictions: restrictions,
        restrictionLifecycleRepository: lifecycleRepository,
      );
      final restrictionState = _restrictionStateWithSession(
        source: RestrictionLifecycleSource.schedule,
        startedAt: DateTime.now().toUtc().subtract(const Duration(minutes: 10)),
        pauseEventsCount: 1,
      );

      await expectLater(
        () => repository.pauseBlocking(const Duration(minutes: 1), mode: _mode, restrictionState: restrictionState),
        throwsA(isA<PauseLimitReachedError>()),
      );
      expect(restrictions.pauseCalls, 0);
      repository.dispose();
    });

    test('rehydrated session state still enforces pause cap', () async {
      final restrictions = _FakeAppRestrictionManager();
      final lifecycleRepository = _FakeRestrictionLifecycleRepository();
      final repository = PauzaBlockingRepository(
        restrictions: restrictions,
        restrictionLifecycleRepository: lifecycleRepository,
      );
      final rehydratedState = _restrictionStateWithSession(
        source: RestrictionLifecycleSource.manual,
        startedAt: DateTime.now().toUtc().subtract(const Duration(minutes: 10)),
        pauseEventsCount: 2,
      );
      final mode = _mode.copyWith(allowedPausesCount: 2);

      await expectLater(
        () => repository.pauseBlocking(const Duration(minutes: 1), mode: mode, restrictionState: rehydratedState),
        throwsA(isA<PauseLimitReachedError>()),
      );
      expect(restrictions.pauseCalls, 0);
      repository.dispose();
    });

    test('throws when active mode data is unavailable', () async {
      final restrictions = _FakeAppRestrictionManager();
      final lifecycleRepository = _FakeRestrictionLifecycleRepository();
      final repository = PauzaBlockingRepository(
        restrictions: restrictions,
        restrictionLifecycleRepository: lifecycleRepository,
      );
      final restrictionState = _restrictionStateWithSession(
        source: RestrictionLifecycleSource.manual,
        startedAt: DateTime.now().toUtc().subtract(const Duration(minutes: 10)),
      );

      await expectLater(
        () => repository.pauseBlocking(const Duration(minutes: 1), mode: null, restrictionState: restrictionState),
        throwsA(isA<ActiveModeUnavailableError>()),
      );
      expect(restrictions.pauseCalls, 0);
      repository.dispose();
    });

    test('closes lifecycle stream on dispose', () async {
      final restrictions = _FakeAppRestrictionManager();
      final lifecycleRepository = _FakeRestrictionLifecycleRepository();
      final repository = PauzaBlockingRepository(
        restrictions: restrictions,
        restrictionLifecycleRepository: lifecycleRepository,
      );
      final done = Completer<void>();
      final subscription = repository.lifecycleActions.listen((_) {}, onDone: done.complete);

      repository.dispose();
      await done.future;

      await subscription.cancel();
    });
  });
}

final Mode _mode = Mode(
  id: 'mode-1',
  title: 'Mode',
  textOnScreen: 'Focus',
  description: null,
  allowedPausesCount: 1,
  minimumDuration: null,
  endingPausingScenario: ModeEndingPausingScenario.manual,
  icon: ModeIconCatalog.defaultIcon,
  schedule: null,
  blockedAppIds: const ISet<AppIdentifier>.empty(),
  createdAt: DateTime(2026, 2, 20).toUtc(),
  updatedAt: DateTime(2026, 2, 20).toUtc(),
);

class _FakeAppRestrictionManager extends AppRestrictionManager {
  int endCalls = 0;
  int pauseCalls = 0;

  @override
  Future<void> startSession(RestrictionMode mode, {Duration? duration}) async {}

  @override
  Future<void> endSession({Duration? duration}) async {
    endCalls += 1;
  }

  @override
  Future<void> pauseEnforcement(Duration duration) async {
    pauseCalls += 1;
  }

  @override
  Future<void> resumeEnforcement() async {}

  @override
  Future<void> configureShield(ShieldConfiguration configuration) async {}
}

class _FakeRestrictionLifecycleRepository implements RestrictionLifecycleRepository {
  @override
  Future<List<RestrictionLifecycleEventLog>> getEvents({String? modeId, String? sessionId, int limit = 500}) async {
    return const <RestrictionLifecycleEventLog>[];
  }

  @override
  Future<List<RestrictionSessionLog>> getSessions({String? modeId, int limit = 200}) async {
    return const <RestrictionSessionLog>[];
  }

  @override
  Future<void> syncFromPluginQueue({int batchSize = 200}) async {}
}

RestrictionState _restrictionStateWithSession({
  required RestrictionLifecycleSource source,
  required DateTime startedAt,
  int pauseEventsCount = 0,
}) {
  final events = <RestrictionLifecycleEvent>[
    RestrictionLifecycleEvent(
      id: 'event-start',
      sessionId: 'session-1',
      modeId: _mode.id,
      action: RestrictionLifecycleAction.start,
      source: source,
      reason: 'start',
      occurredAt: startedAt,
    ),
  ];

  for (var index = 0; index < pauseEventsCount; index++) {
    events.add(
      RestrictionLifecycleEvent(
        id: 'event-pause-$index',
        sessionId: 'session-1',
        modeId: _mode.id,
        action: RestrictionLifecycleAction.pause,
        source: source,
        reason: 'pause',
        occurredAt: startedAt.add(Duration(minutes: index + 1)),
      ),
    );
  }

  return RestrictionState(
    isScheduleEnabled: source == RestrictionLifecycleSource.schedule,
    isInScheduleNow: source == RestrictionLifecycleSource.schedule,
    pausedUntil: null,
    activeMode: RestrictionMode(modeId: _mode.id, blockedAppIds: const <AppIdentifier>[]),
    activeModeSource: source == RestrictionLifecycleSource.schedule
        ? RestrictionModeSource.schedule
        : RestrictionModeSource.manual,
    currentSessionEvents: events,
  );
}
