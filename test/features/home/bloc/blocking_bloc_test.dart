import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/features/home/bloc/blocking_bloc.dart';
import 'package:pauza/src/features/home/data/pauza_blocking_repository.dart';
import 'package:pauza/src/features/modes/common/model/mode.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

void main() {
  group('BlockingBloc', () {
    test('sync maps active mode, startedAt, and pausedUntil', () async {
      final now = DateTime.now().toUtc();
      final startedAt = now.subtract(const Duration(minutes: 15));
      final repository = _FakeBlockingRepository(
        restrictionState: _restrictionState(activeModeId: 'mode-1', startedAt: startedAt, pausedUntil: now.add(const Duration(minutes: 5))),
      );
      final bloc = BlockingBloc(blockingRepository: repository);
      final emitted = <BlockingState>[];
      final sub = bloc.stream.listen(emitted.add);

      bloc.add(const BlockingSyncRequested());
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(emitted, isNotEmpty);
      expect(emitted.last.activeModeId, 'mode-1');
      expect(emitted.last.sessionStartedAt, startedAt);
      expect(emitted.last.pausedUntil, isNotNull);

      await sub.cancel();
      await bloc.close();
    });

    test('sync clears session fields when no active mode exists', () async {
      final now = DateTime.now().toUtc();
      final repository = _FakeBlockingRepository(
        restrictionState: _restrictionState(activeModeId: 'mode-1', startedAt: now.subtract(const Duration(minutes: 5))),
      );
      final bloc = BlockingBloc(blockingRepository: repository);

      bloc.add(const BlockingSyncRequested());
      await Future<void>.delayed(const Duration(milliseconds: 20));

      repository.restrictionState = _restrictionState(activeModeId: null);

      final emitted = <BlockingState>[];
      final sub = bloc.stream.listen(emitted.add);
      bloc.add(const BlockingSyncRequested());
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(emitted, isNotEmpty);
      expect(emitted.last.activeModeId, isNull);
      expect(emitted.last.sessionStartedAt, isNull);
      expect(emitted.last.pausedUntil, isNull);

      await sub.cancel();
      await bloc.close();
    });

    test('quick pause calls repository and emits updated paused state', () async {
      final now = DateTime.now().toUtc();
      final startedAt = now.subtract(const Duration(minutes: 30));
      final repository = _FakeBlockingRepository(
        restrictionState: _restrictionState(activeModeId: 'mode-1', startedAt: startedAt),
      );
      final bloc = BlockingBloc(blockingRepository: repository);

      bloc.add(const BlockingSyncRequested());
      await Future<void>.delayed(const Duration(milliseconds: 20));

      final emitted = <BlockingState>[];
      final sub = bloc.stream.listen(emitted.add);
      bloc.add(const BlockingQuickPauseRequested(Duration(minutes: 5)));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(repository.pauseDurations, <Duration>[const Duration(minutes: 5)]);
      expect(emitted, isNotEmpty);
      expect(emitted.last.pausedUntil, isNotNull);
      expect(emitted.last.activeModeId, 'mode-1');

      await sub.cancel();
      await bloc.close();
    });

    test('stop clears active mode and session fields', () async {
      final now = DateTime.now().toUtc();
      final repository = _FakeBlockingRepository(
        restrictionState: _restrictionState(activeModeId: 'mode-1', startedAt: now.subtract(const Duration(minutes: 5))),
      );
      final bloc = BlockingBloc(blockingRepository: repository);
      final emitted = <BlockingState>[];
      final sub = bloc.stream.listen(emitted.add);

      bloc.add(const BlockingSyncRequested());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      bloc.add(const BlockingStopRequested());
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(repository.stopCallCount, 1);
      expect(emitted, isNotEmpty);
      expect(emitted.last.activeModeId, isNull);
      expect(emitted.last.sessionStartedAt, isNull);
      expect(emitted.last.pausedUntil, isNull);

      await sub.cancel();
      await bloc.close();
    });

    test('resume clears pausedUntil and keeps active session', () async {
      final now = DateTime.now().toUtc();
      final repository = _FakeBlockingRepository(
        restrictionState: _restrictionState(
          activeModeId: 'mode-1',
          startedAt: now.subtract(const Duration(minutes: 5)),
          pausedUntil: now.add(const Duration(minutes: 5)),
        ),
      );
      final bloc = BlockingBloc(blockingRepository: repository);

      bloc.add(const BlockingSyncRequested());
      await Future<void>.delayed(const Duration(milliseconds: 20));

      final emitted = <BlockingState>[];
      final sub = bloc.stream.listen(emitted.add);
      bloc.add(const BlockingResumeRequested());
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(repository.resumeCallCount, 1);
      expect(emitted, isNotEmpty);
      expect(emitted.last.activeModeId, 'mode-1');
      expect(emitted.last.pausedUntil, isNull);

      await sub.cancel();
      await bloc.close();
    });
  });
}

class _FakeBlockingRepository implements BlockingRepository {
  _FakeBlockingRepository({required this.restrictionState});

  RestrictionState restrictionState;
  int stopCallCount = 0;
  int resumeCallCount = 0;
  final List<Duration> pauseDurations = <Duration>[];

  @override
  Future<RestrictionState> getRestrictionSession() async => restrictionState;

  @override
  Future<void> pauseBlocking(Duration duration) async {
    pauseDurations.add(duration);
    restrictionState = _restrictionState(
      activeModeId: restrictionState.activeMode?.modeId,
      startedAt: restrictionState.startedAt,
      pausedUntil: DateTime.now().toUtc().add(duration),
    );
  }

  @override
  Future<void> startBlocking({required Mode mode, required ShieldConfiguration? shield}) async {
    restrictionState = _restrictionState(activeModeId: mode.id, startedAt: DateTime.now().toUtc());
  }

  @override
  Future<void> stopBlocking() async {
    stopCallCount += 1;
    restrictionState = _restrictionState(activeModeId: null);
  }

  @override
  Future<void> resumeBlocking() async {
    resumeCallCount += 1;
    restrictionState = _restrictionState(activeModeId: restrictionState.activeMode?.modeId, startedAt: restrictionState.startedAt);
  }

  @override
  Future<void> syncRestrictionLifecycleEvents() async {}
}

RestrictionState _restrictionState({required String? activeModeId, DateTime? startedAt, DateTime? pausedUntil}) {
  final currentSessionEvents = startedAt == null || activeModeId == null
      ? const <RestrictionLifecycleEvent>[]
      : <RestrictionLifecycleEvent>[
          RestrictionLifecycleEvent(
            id: 'event-1',
            sessionId: 'session-1',
            modeId: activeModeId,
            action: RestrictionLifecycleAction.start,
            source: RestrictionLifecycleSource.manual,
            reason: 'manual_start',
            occurredAt: startedAt,
          ),
        ];

  return RestrictionState(
    isScheduleEnabled: false,
    isInScheduleNow: false,
    pausedUntil: pausedUntil,
    activeMode: activeModeId == null ? null : RestrictionMode(modeId: activeModeId, blockedAppIds: const <AppIdentifier>[]),
    activeModeSource: activeModeId == null ? RestrictionModeSource.none : RestrictionModeSource.manual,
    currentSessionEvents: currentSessionEvents,
  );
}
