import 'package:flutter_test/flutter_test.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:pauza/src/features/home/bloc/blocking_bloc.dart';
import 'package:pauza/src/features/home/data/pauza_blocking_repository.dart';
import 'package:pauza/src/features/home/model/blocking_action_error.dart';
import 'package:pauza/src/features/modes/common/data/modes_repository.dart';
import 'package:pauza/src/features/modes/common/model/mode.dart';
import 'package:pauza/src/features/modes/common/model/mode_ending_pausing_scenario.dart';
import 'package:pauza/src/features/modes/common/model/mode_icon.dart';
import 'package:pauza/src/features/modes/common/model/mode_upsert.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

void main() {
  group('BlockingBloc', () {
    test('sync maps active mode, startedAt, and pausedUntil', () async {
      final now = DateTime.now().toUtc();
      final startedAt = now.subtract(const Duration(minutes: 15));
      final repository = _FakeBlockingRepository(
        restrictionState: _restrictionState(
          activeModeId: 'mode-1',
          startedAt: startedAt,
          pausedUntil: now.add(const Duration(minutes: 5)),
        ),
      );
      final modesRepository = _FakeModesRepository();
      final bloc = BlockingBloc(blockingRepository: repository, modesRepository: modesRepository);
      final emitted = <BlockingState>[];
      final sub = bloc.stream.listen(emitted.add);

      bloc.add(const BlockingSyncRequested());
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(emitted, isNotEmpty);
      expect(emitted.last.restrictionState.activeMode?.modeId, 'mode-1');
      expect(emitted.last.activeMode?.id, 'mode-1');
      expect(emitted.last.sessionStartedAt, startedAt);
      expect(emitted.last.pausedUntil, isNotNull);

      await sub.cancel();
      await bloc.close();
    });

    test('sync clears session fields when no active mode exists', () async {
      final now = DateTime.now().toUtc();
      final repository = _FakeBlockingRepository(
        restrictionState: _restrictionState(
          activeModeId: 'mode-1',
          startedAt: now.subtract(const Duration(minutes: 5)),
        ),
      );
      final modesRepository = _FakeModesRepository();
      final bloc = BlockingBloc(blockingRepository: repository, modesRepository: modesRepository);

      bloc.add(const BlockingSyncRequested());
      await Future<void>.delayed(const Duration(milliseconds: 20));

      repository.restrictionState = _restrictionState(activeModeId: null);

      final emitted = <BlockingState>[];
      final sub = bloc.stream.listen(emitted.add);
      bloc.add(const BlockingSyncRequested());
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(emitted, isNotEmpty);
      expect(emitted.last.restrictionState.activeMode, isNull);
      expect(emitted.last.activeMode, isNull);
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
      final modesRepository = _FakeModesRepository();
      final bloc = BlockingBloc(blockingRepository: repository, modesRepository: modesRepository);

      bloc.add(const BlockingSyncRequested());
      await Future<void>.delayed(const Duration(milliseconds: 20));

      final emitted = <BlockingState>[];
      final sub = bloc.stream.listen(emitted.add);
      bloc.add(const BlockingQuickPauseRequested(Duration(minutes: 5)));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(repository.pauseDurations, <Duration>[const Duration(minutes: 5)]);
      expect(emitted, isNotEmpty);
      expect(emitted.last.pausedUntil, isNotNull);
      expect(emitted.last.restrictionState.activeMode?.modeId, 'mode-1');

      await sub.cancel();
      await bloc.close();
    });

    test('stop clears active mode and session fields', () async {
      final now = DateTime.now().toUtc();
      final repository = _FakeBlockingRepository(
        restrictionState: _restrictionState(
          activeModeId: 'mode-1',
          startedAt: now.subtract(const Duration(minutes: 5)),
        ),
      );
      final modesRepository = _FakeModesRepository();
      final bloc = BlockingBloc(blockingRepository: repository, modesRepository: modesRepository);
      final emitted = <BlockingState>[];
      final sub = bloc.stream.listen(emitted.add);

      bloc.add(const BlockingSyncRequested());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      bloc.add(const BlockingStopRequested());
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(repository.stopCallCount, 1);
      expect(emitted, isNotEmpty);
      expect(emitted.last.restrictionState.activeMode, isNull);
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
      final modesRepository = _FakeModesRepository();
      final bloc = BlockingBloc(blockingRepository: repository, modesRepository: modesRepository);

      bloc.add(const BlockingSyncRequested());
      await Future<void>.delayed(const Duration(milliseconds: 20));

      final emitted = <BlockingState>[];
      final sub = bloc.stream.listen(emitted.add);
      bloc.add(const BlockingResumeRequested());
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(repository.resumeCallCount, 1);
      expect(emitted, isNotEmpty);
      expect(emitted.last.restrictionState.activeMode?.modeId, 'mode-1');
      expect(emitted.last.pausedUntil, isNull);

      await sub.cancel();
      await bloc.close();
    });

    test('pause limit exception is mapped to action error', () async {
      final repository = _FakeBlockingRepository(
        restrictionState: _restrictionState(activeModeId: 'mode-1', startedAt: DateTime.now().toUtc()),
      )..pauseError = const PauseLimitReachedError();
      final modesRepository = _FakeModesRepository();
      final bloc = BlockingBloc(blockingRepository: repository, modesRepository: modesRepository);

      bloc.add(const BlockingSyncRequested());
      await Future<void>.delayed(const Duration(milliseconds: 20));

      final emitted = <BlockingState>[];
      final sub = bloc.stream.listen(emitted.add);
      bloc.add(const BlockingQuickPauseRequested(Duration(minutes: 5)));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(emitted, isNotEmpty);
      expect(emitted.last.actionError, isA<PauseLimitReachedError>());
      expect(emitted.last.error, isNull);

      await sub.cancel();
      await bloc.close();
    });

    test('sync keeps activeMode null when mode lookup fails', () async {
      final repository = _FakeBlockingRepository(
        restrictionState: _restrictionState(activeModeId: 'missing-mode', startedAt: DateTime.now().toUtc()),
      );
      final modesRepository = _FakeModesRepository(shouldThrowOnGetMode: true);
      final bloc = BlockingBloc(blockingRepository: repository, modesRepository: modesRepository);

      final emitted = <BlockingState>[];
      final sub = bloc.stream.listen(emitted.add);
      bloc.add(const BlockingSyncRequested());
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(emitted, isNotEmpty);
      expect(emitted.last.activeMode, isNull);

      await sub.cancel();
      await bloc.close();
    });
  });
}

class _FakeBlockingRepository implements BlockingRepository {
  _FakeBlockingRepository({required this.restrictionState});

  RestrictionState restrictionState;
  BlockingActionError? pauseError;
  BlockingActionError? stopError;
  int stopCallCount = 0;
  int resumeCallCount = 0;
  final List<Duration> pauseDurations = <Duration>[];
  final Stream<RestrictionLifecycleAction> _lifecycleActions = const Stream<RestrictionLifecycleAction>.empty();

  @override
  Stream<RestrictionLifecycleAction> get lifecycleActions => _lifecycleActions;

  @override
  Future<RestrictionState> getRestrictionSession() async => restrictionState;

  @override
  Future<void> pauseBlocking(
    Duration duration, {
    required Mode? mode,
    required RestrictionState restrictionState,
  }) async {
    final error = pauseError;
    if (error != null) {
      throw error;
    }
    pauseDurations.add(duration);
    this.restrictionState = _restrictionState(
      activeModeId: this.restrictionState.activeMode?.modeId,
      startedAt: this.restrictionState.startedAt,
      pausedUntil: DateTime.now().toUtc().add(duration),
    );
  }

  @override
  Future<void> startBlocking({required Mode mode, required ShieldConfiguration? shield}) async {
    restrictionState = _restrictionState(activeModeId: mode.id, startedAt: DateTime.now().toUtc());
  }

  @override
  Future<void> stopBlocking({
    required Mode? mode,
    required RestrictionState restrictionState,
    Duration? cooldownDuration,
  }) async {
    final error = stopError;
    if (error != null) {
      throw error;
    }
    stopCallCount += 1;
    this.restrictionState = _restrictionState(activeModeId: null);
  }

  @override
  Future<void> resumeBlocking() async {
    resumeCallCount += 1;
    restrictionState = _restrictionState(
      activeModeId: restrictionState.activeMode?.modeId,
      startedAt: restrictionState.startedAt,
    );
  }

  @override
  Future<void> syncRestrictionLifecycleEvents() async {}

  @override
  void dispose() {}
}

class _FakeModesRepository implements ModesRepository {
  _FakeModesRepository({this.shouldThrowOnGetMode = false});

  final bool shouldThrowOnGetMode;

  @override
  Future<void> createMode(ModeUpsertDTO request) async {}

  @override
  Future<void> deleteMode(String modeId) async {}

  @override
  Future<Mode> getMode(String modeId) async {
    if (shouldThrowOnGetMode) {
      throw Exception('Mode not found');
    }
    return _mode.copyWith();
  }

  @override
  Future<List<Mode>> getModes() async => <Mode>[_mode];

  @override
  Future<void> updateMode({required String modeId, required ModeUpsertDTO request}) async {}

  @override
  Stream<void> watchModes() => const Stream<void>.empty();

  @override
  void dispose() {}

  static final Mode _mode = Mode(
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
    activeMode: activeModeId == null
        ? null
        : RestrictionMode(modeId: activeModeId, blockedAppIds: const <AppIdentifier>[]),
    activeModeSource: activeModeId == null ? RestrictionModeSource.none : RestrictionModeSource.manual,
    currentSessionEvents: currentSessionEvents,
  );
}
