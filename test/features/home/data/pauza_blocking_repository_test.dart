import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pauza/src/features/home/data/pauza_blocking_repository.dart';
import 'package:pauza/src/features/home/model/blocking_action_error.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

import '../../../helpers/helpers.dart';

void main() {
  group('PauzaBlockingRepository', () {
    late FakeAppRestrictionManager restrictions;
    late MockRestrictionLifecycleRepository lifecycleRepository;

    setUp(() {
      restrictions = FakeAppRestrictionManager();
      lifecycleRepository = MockRestrictionLifecycleRepository();
      when(() => lifecycleRepository.syncFromPluginQueue()).thenAnswer((_) async {});
    });

    test('emits lifecycle actions for start, pause, resume, and stop', () async {
      final repository = PauzaBlockingRepository(
        restrictions: restrictions,
        restrictionLifecycleRepository: lifecycleRepository,
      );
      final emittedActions = <RestrictionLifecycleAction>[];
      final subscription = repository.lifecycleActions.listen(emittedActions.add);
      final mode = makeMode();
      final restrictionState = makeRestrictionState(
        activeMode: RestrictionMode(modeId: mode.id, blockedAppIds: const <AppIdentifier>[]),
        activeModeSource: RestrictionModeSource.manual,
        currentSessionEvents: <RestrictionLifecycleEvent>[
          RestrictionLifecycleEvent(
            id: 'event-start',
            sessionId: 'session-1',
            modeId: mode.id,
            action: RestrictionLifecycleAction.start,
            source: RestrictionLifecycleSource.manual,
            reason: 'start',
            occurredAt: DateTime.now().toUtc().subtract(const Duration(minutes: 10)),
          ),
        ],
      );

      await repository.startBlocking(mode: mode, shield: null);
      await repository.pauseBlocking(const Duration(minutes: 1), mode: mode, restrictionState: restrictionState);
      await repository.resumeBlocking();
      await repository.stopBlocking(mode: mode, restrictionState: restrictionState);
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
      final repository = PauzaBlockingRepository(
        restrictions: restrictions,
        restrictionLifecycleRepository: lifecycleRepository,
      );
      final mode = makeMode();
      final restrictionState = _restrictionStateWithSession(
        modeId: mode.id,
        source: RestrictionLifecycleSource.manual,
        startedAt: DateTime.now().toUtc().subtract(const Duration(minutes: 10)),
      );

      await repository.pauseBlocking(const Duration(minutes: 1), mode: mode, restrictionState: restrictionState);

      expect(restrictions.pauseCalls, 1);
      repository.dispose();
    });

    test('pause rejected at or above pause limit', () async {
      final repository = PauzaBlockingRepository(
        restrictions: restrictions,
        restrictionLifecycleRepository: lifecycleRepository,
      );
      final mode = makeMode();
      final restrictionState = _restrictionStateWithSession(
        modeId: mode.id,
        source: RestrictionLifecycleSource.manual,
        startedAt: DateTime.now().toUtc().subtract(const Duration(minutes: 10)),
        pauseEventsCount: 1,
      );

      await expectLater(
        () => repository.pauseBlocking(const Duration(minutes: 1), mode: mode, restrictionState: restrictionState),
        throwsA(isA<PauseLimitReachedError>()),
      );
      expect(restrictions.pauseCalls, 0);
      repository.dispose();
    });

    test('end rejected before minimum duration', () async {
      final repository = PauzaBlockingRepository(
        restrictions: restrictions,
        restrictionLifecycleRepository: lifecycleRepository,
      );
      final mode = makeMode(minimumDuration: const Duration(minutes: 30));
      final restrictionState = _restrictionStateWithSession(
        modeId: mode.id,
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
      final repository = PauzaBlockingRepository(
        restrictions: restrictions,
        restrictionLifecycleRepository: lifecycleRepository,
      );
      final mode = makeMode(minimumDuration: const Duration(minutes: 30));
      final restrictionState = _restrictionStateWithSession(
        modeId: mode.id,
        source: RestrictionLifecycleSource.manual,
        startedAt: DateTime.now().toUtc().subtract(const Duration(minutes: 5)),
      );

      await repository.pauseBlocking(const Duration(minutes: 1), mode: mode, restrictionState: restrictionState);

      expect(restrictions.pauseCalls, 1);
      repository.dispose();
    });

    test('end accepted when minimum duration reached', () async {
      final repository = PauzaBlockingRepository(
        restrictions: restrictions,
        restrictionLifecycleRepository: lifecycleRepository,
      );
      final mode = makeMode(minimumDuration: const Duration(minutes: 10));
      final restrictionState = _restrictionStateWithSession(
        modeId: mode.id,
        source: RestrictionLifecycleSource.manual,
        startedAt: DateTime.now().toUtc().subtract(const Duration(minutes: 11)),
      );

      await repository.stopBlocking(mode: mode, restrictionState: restrictionState);

      expect(restrictions.endCalls, 1);
      repository.dispose();
    });

    test('schedule source enforces rules same as manual source', () async {
      final repository = PauzaBlockingRepository(
        restrictions: restrictions,
        restrictionLifecycleRepository: lifecycleRepository,
      );
      final mode = makeMode();
      final restrictionState = _restrictionStateWithSession(
        modeId: mode.id,
        source: RestrictionLifecycleSource.schedule,
        startedAt: DateTime.now().toUtc().subtract(const Duration(minutes: 10)),
        pauseEventsCount: 1,
      );

      await expectLater(
        () => repository.pauseBlocking(const Duration(minutes: 1), mode: mode, restrictionState: restrictionState),
        throwsA(isA<PauseLimitReachedError>()),
      );
      expect(restrictions.pauseCalls, 0);
      repository.dispose();
    });

    test('rehydrated session state still enforces pause cap', () async {
      final repository = PauzaBlockingRepository(
        restrictions: restrictions,
        restrictionLifecycleRepository: lifecycleRepository,
      );
      final mode = makeMode(allowedPausesCount: 2);
      final rehydratedState = _restrictionStateWithSession(
        modeId: mode.id,
        source: RestrictionLifecycleSource.manual,
        startedAt: DateTime.now().toUtc().subtract(const Duration(minutes: 10)),
        pauseEventsCount: 2,
      );

      await expectLater(
        () => repository.pauseBlocking(const Duration(minutes: 1), mode: mode, restrictionState: rehydratedState),
        throwsA(isA<PauseLimitReachedError>()),
      );
      expect(restrictions.pauseCalls, 0);
      repository.dispose();
    });

    test('throws when active mode data is unavailable', () async {
      final repository = PauzaBlockingRepository(
        restrictions: restrictions,
        restrictionLifecycleRepository: lifecycleRepository,
      );
      final restrictionState = _restrictionStateWithSession(
        modeId: 'mode-1',
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

class FakeAppRestrictionManager extends AppRestrictionManager {
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

RestrictionState _restrictionStateWithSession({
  required String modeId,
  required RestrictionLifecycleSource source,
  required DateTime startedAt,
  int pauseEventsCount = 0,
}) {
  final events = <RestrictionLifecycleEvent>[
    RestrictionLifecycleEvent(
      id: 'event-start',
      sessionId: 'session-1',
      modeId: modeId,
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
        modeId: modeId,
        action: RestrictionLifecycleAction.pause,
        source: source,
        reason: 'pause',
        occurredAt: startedAt.add(Duration(minutes: index + 1)),
      ),
    );
  }

  return makeRestrictionState(
    isScheduleEnabled: source == RestrictionLifecycleSource.schedule,
    isInScheduleNow: source == RestrictionLifecycleSource.schedule,
    activeMode: RestrictionMode(modeId: modeId, blockedAppIds: const <AppIdentifier>[]),
    activeModeSource: source == RestrictionLifecycleSource.schedule
        ? RestrictionModeSource.schedule
        : RestrictionModeSource.manual,
    currentSessionEvents: events,
  );
}
