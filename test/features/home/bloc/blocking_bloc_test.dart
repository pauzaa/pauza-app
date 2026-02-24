import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/features/home/bloc/blocking_bloc.dart';
import 'package:pauza/src/features/home/data/pauza_blocking_repository.dart';
import 'package:pauza/src/features/home/model/blocking_action_error.dart';
import 'package:pauza/src/features/home/model/blocking_action_proof.dart';
import 'package:pauza/src/features/modes/common/data/modes_repository.dart';
import 'package:pauza/src/features/modes/common/model/mode.dart';
import 'package:pauza/src/features/modes/common/model/mode_ending_pausing_scenario.dart';
import 'package:pauza/src/features/modes/common/model/mode_icon.dart';
import 'package:pauza/src/features/modes/common/model/mode_upsert.dart';
import 'package:pauza/src/features/nfc/model/nfc_chip_identifier.dart';
import 'package:pauza/src/features/nfc_chip_config/data/nfc_linked_chips_repository.dart';
import 'package:pauza/src/features/nfc_chip_config/model/nfc_linked_chip.dart';
import 'package:pauza/src/features/qr_code_config/data/qr_linked_codes_repository.dart';
import 'package:pauza/src/features/qr_code_config/model/qr_linked_code.dart';
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
      final bloc = _createBloc(repository: repository, modesRepository: modesRepository);
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
      final bloc = _createBloc(repository: repository, modesRepository: modesRepository);

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
      final bloc = _createBloc(repository: repository, modesRepository: modesRepository);

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
      final bloc = _createBloc(repository: repository, modesRepository: modesRepository);
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
      final bloc = _createBloc(repository: repository, modesRepository: modesRepository);

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
      final bloc = _createBloc(repository: repository, modesRepository: modesRepository);

      bloc.add(const BlockingSyncRequested());
      await Future<void>.delayed(const Duration(milliseconds: 20));

      final emitted = <BlockingState>[];
      final sub = bloc.stream.listen(emitted.add);
      bloc.add(const BlockingQuickPauseRequested(Duration(minutes: 5)));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(emitted, isNotEmpty);
      expect(emitted.last.error, isA<PauseLimitReachedError>());

      await sub.cancel();
      await bloc.close();
    });

    test('sync keeps activeMode null when mode lookup fails', () async {
      final repository = _FakeBlockingRepository(
        restrictionState: _restrictionState(activeModeId: 'missing-mode', startedAt: DateTime.now().toUtc()),
      );
      final modesRepository = _FakeModesRepository(shouldThrowOnGetMode: true);
      final bloc = _createBloc(repository: repository, modesRepository: modesRepository);

      final emitted = <BlockingState>[];
      final sub = bloc.stream.listen(emitted.add);
      bloc.add(const BlockingSyncRequested());
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(emitted, isNotEmpty);
      expect(emitted.last.activeMode, isNull);

      await sub.cancel();
      await bloc.close();
    });

    test('nfc scenario requires scan proof', () async {
      final repository = _FakeBlockingRepository(
        restrictionState: _restrictionState(activeModeId: 'mode-1', startedAt: DateTime.now().toUtc()),
      );
      final modesRepository = _FakeModesRepository(mode: _modeFor(ModeEndingPausingScenario.nfc));
      final bloc = _createBloc(repository: repository, modesRepository: modesRepository);
      final emitted = <BlockingState>[];
      final sub = bloc.stream.listen(emitted.add);

      bloc.add(const BlockingSyncRequested());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      bloc.add(const BlockingQuickPauseRequested(Duration(minutes: 5)));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(emitted.last.error, isA<ScenarioProofRequiredError>());
      expect(repository.pauseDurations, isEmpty);

      await sub.cancel();
      await bloc.close();
    });

    test('nfc scenario rejects unlinked chip', () async {
      final repository = _FakeBlockingRepository(
        restrictionState: _restrictionState(activeModeId: 'mode-1', startedAt: DateTime.now().toUtc()),
      );
      final modesRepository = _FakeModesRepository(mode: _modeFor(ModeEndingPausingScenario.nfc));
      const nfcRepository = _FakeNfcLinkedChipsRepository(hasChipResult: false);
      final bloc = _createBloc(repository: repository, modesRepository: modesRepository, nfcRepository: nfcRepository);
      final emitted = <BlockingState>[];
      final sub = bloc.stream.listen(emitted.add);

      bloc.add(const BlockingSyncRequested());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      bloc.add(
        BlockingQuickPauseRequested(
          const Duration(minutes: 5),
          proof: NfcActionProof(chipIdentifier: NfcChipIdentifier.parse('a1b2')),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(emitted.last.error, isA<NfcChipNotLinkedError>());
      expect(repository.pauseDurations, isEmpty);

      await sub.cancel();
      await bloc.close();
    });

    test('nfc scenario accepts linked chip', () async {
      final repository = _FakeBlockingRepository(
        restrictionState: _restrictionState(activeModeId: 'mode-1', startedAt: DateTime.now().toUtc()),
      );
      final modesRepository = _FakeModesRepository(mode: _modeFor(ModeEndingPausingScenario.nfc));
      const nfcRepository = _FakeNfcLinkedChipsRepository(hasChipResult: true);
      final bloc = _createBloc(repository: repository, modesRepository: modesRepository, nfcRepository: nfcRepository);

      bloc.add(const BlockingSyncRequested());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      bloc.add(
        BlockingQuickPauseRequested(
          const Duration(minutes: 5),
          proof: NfcActionProof(chipIdentifier: NfcChipIdentifier.parse('a1b2')),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(repository.pauseDurations, <Duration>[const Duration(minutes: 5)]);

      await bloc.close();
    });

    test('qr scenario rejects invalid payload', () async {
      final repository = _FakeBlockingRepository(
        restrictionState: _restrictionState(activeModeId: 'mode-1', startedAt: DateTime.now().toUtc()),
      );
      final modesRepository = _FakeModesRepository(mode: _modeFor(ModeEndingPausingScenario.qrCode));
      final bloc = _createBloc(repository: repository, modesRepository: modesRepository);
      final emitted = <BlockingState>[];
      final sub = bloc.stream.listen(emitted.add);

      bloc.add(const BlockingSyncRequested());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      bloc.add(const BlockingStopRequested(proof: QrActionProof(rawValue: 'bad-value')));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(emitted.last.error, isA<QrCodeInvalidError>());
      expect(repository.stopCallCount, 0);

      await sub.cancel();
      await bloc.close();
    });

    test('qr scenario rejects non-linked code', () async {
      final repository = _FakeBlockingRepository(
        restrictionState: _restrictionState(activeModeId: 'mode-1', startedAt: DateTime.now().toUtc()),
      );
      final modesRepository = _FakeModesRepository(mode: _modeFor(ModeEndingPausingScenario.qrCode));
      const qrRepository = _FakeQrLinkedCodesRepository(hasScanValueResult: false);
      final bloc = _createBloc(repository: repository, modesRepository: modesRepository, qrRepository: qrRepository);
      final emitted = <BlockingState>[];
      final sub = bloc.stream.listen(emitted.add);

      bloc.add(const BlockingSyncRequested());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      bloc.add(const BlockingStopRequested(proof: QrActionProof(rawValue: _validQrToken)));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(emitted.last.error, isA<QrCodeNotLinkedError>());
      expect(repository.stopCallCount, 0);

      await sub.cancel();
      await bloc.close();
    });

    test('qr scenario accepts linked code', () async {
      final repository = _FakeBlockingRepository(
        restrictionState: _restrictionState(activeModeId: 'mode-1', startedAt: DateTime.now().toUtc()),
      );
      final modesRepository = _FakeModesRepository(mode: _modeFor(ModeEndingPausingScenario.qrCode));
      const qrRepository = _FakeQrLinkedCodesRepository(hasScanValueResult: true);
      final bloc = _createBloc(repository: repository, modesRepository: modesRepository, qrRepository: qrRepository);

      bloc.add(const BlockingSyncRequested());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      bloc.add(const BlockingStopRequested(proof: QrActionProof(rawValue: _validQrToken)));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(repository.stopCallCount, 1);

      await bloc.close();
    });
  });
}

BlockingBloc _createBloc({
  required BlockingRepository repository,
  required ModesRepository modesRepository,
  NfcLinkedChipsRepository? nfcRepository,
  QrLinkedCodesRepository? qrRepository,
}) {
  return BlockingBloc(
    blockingRepository: repository,
    modesRepository: modesRepository,
    nfcLinkedChipsRepository: nfcRepository ?? const _FakeNfcLinkedChipsRepository(hasChipResult: true),
    qrLinkedCodesRepository: qrRepository ?? const _FakeQrLinkedCodesRepository(hasScanValueResult: true),
  );
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
  _FakeModesRepository({this.shouldThrowOnGetMode = false, Mode? mode}) : _mode = mode ?? _defaultMode;

  final bool shouldThrowOnGetMode;
  final Mode _mode;

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

  static final Mode _defaultMode = Mode(
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

final class _FakeNfcLinkedChipsRepository implements NfcLinkedChipsRepository {
  const _FakeNfcLinkedChipsRepository({required this.hasChipResult});

  final bool hasChipResult;

  @override
  Future<void> deleteChip({required String id}) async {}

  @override
  Future<IList<NfcLinkedChip>> getLinkedChips() async => const IListConst<NfcLinkedChip>(<NfcLinkedChip>[]);

  @override
  Future<bool> hasChip({required NfcChipIdentifier chipIdentifier}) async => hasChipResult;

  @override
  Future<bool> linkChipIfAbsent({required NfcChipIdentifier chipIdentifier}) async => true;

  @override
  Future<void> renameChip({required String id, required String name}) async {}
}

final class _FakeQrLinkedCodesRepository implements QrLinkedCodesRepository {
  const _FakeQrLinkedCodesRepository({required this.hasScanValueResult});

  final bool hasScanValueResult;

  @override
  Future<void> deleteCode({required String id}) async {}

  @override
  Future<QrLinkedCode> generateAndLinkCode() {
    throw UnimplementedError();
  }

  @override
  Future<IList<QrLinkedCode>> getLinkedCodes() async => const IListConst<QrLinkedCode>(<QrLinkedCode>[]);

  @override
  Future<bool> hasScanValue({required String scanValue}) async => hasScanValueResult;

  @override
  Future<void> renameCode({required String id, required String name}) async {}
}

Mode _modeFor(ModeEndingPausingScenario scenario) {
  return _FakeModesRepository._defaultMode.copyWith(endingPausingScenario: scenario);
}

const String _validQrToken = 'pauza:qr:v1:123e4567-e89b-42d3-a456-426614174000';

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
