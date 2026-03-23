import 'package:bloc_test/bloc_test.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pauza/src/features/home/bloc/blocking_bloc.dart';
import 'package:pauza/src/features/home/data/pauza_blocking_repository.dart';
import 'package:pauza/src/features/home/model/blocking_action_error.dart';
import 'package:pauza/src/features/home/model/blocking_action_proof.dart';
import 'package:pauza/src/features/modes/common/model/mode.dart';
import 'package:pauza/src/features/modes/common/model/mode_ending_pausing_scenario.dart';
import 'package:pauza/src/features/nfc/model/nfc_chip_identifier.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

import '../../../helpers/helpers.dart';

const String _validQrToken = 'pauza:qr:v1:123e4567-e89b-42d3-a456-426614174000';

void main() {
  late MockModesRepository modesRepository;
  late MockNfcLinkedChipsRepository nfcRepository;
  late MockQrLinkedCodesRepository qrRepository;
  late MockEmergencyStopRepository emergencyStopRepository;
  late MockInternetRequiredGuard internetRequiredGuard;

  setUpAll(registerTestFallbackValues);

  setUp(() {
    modesRepository = MockModesRepository();
    nfcRepository = MockNfcLinkedChipsRepository();
    qrRepository = MockQrLinkedCodesRepository();
    emergencyStopRepository = MockEmergencyStopRepository();
    internetRequiredGuard = MockInternetRequiredGuard();

    // Default stubs for shared mocks.
    when(() => modesRepository.getMode(any())).thenAnswer((_) async => makeMode());
    when(() => nfcRepository.hasChip(chipIdentifier: any(named: 'chipIdentifier'))).thenAnswer((_) async => true);
    when(() => nfcRepository.hasLinkedChips()).thenAnswer((_) async => true);
    when(() => qrRepository.hasScanValue(scanValue: any(named: 'scanValue'))).thenAnswer((_) async => true);
    when(() => qrRepository.hasLinkedCodes()).thenAnswer((_) async => true);
  });

  group('BlockingBloc', () {
    blocTest<BlockingBloc, BlockingState>(
      'sync maps active mode, startedAt, and pausedUntil',
      build: () {
        final now = DateTime.now().toUtc();
        final startedAt = now.subtract(const Duration(minutes: 15));
        final repository = FakeBlockingRepository(
          restrictionState: _restrictionState(
            activeModeId: 'mode-1',
            startedAt: startedAt,
            pausedUntil: now.add(const Duration(minutes: 5)),
          ),
        );
        return BlockingBloc(
          blockingRepository: repository,
          modesRepository: modesRepository,
          nfcLinkedChipsRepository: nfcRepository,
          qrLinkedCodesRepository: qrRepository,
          emergencyStopRepository: emergencyStopRepository,
          internetRequiredGuard: internetRequiredGuard,
        );
      },
      act: (bloc) => bloc.add(const BlockingSyncRequested()),
      verify: (bloc) {
        expect(bloc.state.restrictionState.activeMode?.modeId, 'mode-1');
        expect(bloc.state.activeMode?.id, 'mode-1');
        expect(bloc.state.sessionStartedAt, isNotNull);
        expect(bloc.state.pausedUntil, isNotNull);
      },
    );

    blocTest<BlockingBloc, BlockingState>(
      'sync clears session fields when no active mode exists',
      build: () {
        final repository = FakeBlockingRepository(restrictionState: _restrictionState(activeModeId: null));
        return BlockingBloc(
          blockingRepository: repository,
          modesRepository: modesRepository,
          nfcLinkedChipsRepository: nfcRepository,
          qrLinkedCodesRepository: qrRepository,
          emergencyStopRepository: emergencyStopRepository,
          internetRequiredGuard: internetRequiredGuard,
        );
      },
      act: (bloc) => bloc.add(const BlockingSyncRequested()),
      verify: (bloc) {
        expect(bloc.state.restrictionState.activeMode, isNull);
        expect(bloc.state.activeMode, isNull);
        expect(bloc.state.sessionStartedAt, isNull);
        expect(bloc.state.pausedUntil, isNull);
      },
    );

    blocTest<BlockingBloc, BlockingState>(
      'quick pause calls repository and emits updated paused state',
      build: () {
        final now = DateTime.now().toUtc();
        final startedAt = now.subtract(const Duration(minutes: 30));
        final repository = FakeBlockingRepository(
          restrictionState: _restrictionState(activeModeId: 'mode-1', startedAt: startedAt),
        );
        return BlockingBloc(
          blockingRepository: repository,
          modesRepository: modesRepository,
          nfcLinkedChipsRepository: nfcRepository,
          qrLinkedCodesRepository: qrRepository,
          emergencyStopRepository: emergencyStopRepository,
          internetRequiredGuard: internetRequiredGuard,
        );
      },
      act: (bloc) async {
        bloc.add(const BlockingSyncRequested());
        await Future<void>.delayed(const Duration(milliseconds: 20));
        bloc.add(const BlockingQuickPauseRequested(Duration(minutes: 5)));
      },
      verify: (bloc) {
        expect(bloc.state.pausedUntil, isNotNull);
        expect(bloc.state.restrictionState.activeMode?.modeId, 'mode-1');
      },
    );

    blocTest<BlockingBloc, BlockingState>(
      'stop clears active mode and session fields',
      build: () {
        final now = DateTime.now().toUtc();
        final repository = FakeBlockingRepository(
          restrictionState: _restrictionState(
            activeModeId: 'mode-1',
            startedAt: now.subtract(const Duration(minutes: 5)),
          ),
        );
        return BlockingBloc(
          blockingRepository: repository,
          modesRepository: modesRepository,
          nfcLinkedChipsRepository: nfcRepository,
          qrLinkedCodesRepository: qrRepository,
          emergencyStopRepository: emergencyStopRepository,
          internetRequiredGuard: internetRequiredGuard,
        );
      },
      act: (bloc) async {
        bloc.add(const BlockingSyncRequested());
        await Future<void>.delayed(const Duration(milliseconds: 20));
        bloc.add(const BlockingStopRequested());
      },
      verify: (bloc) {
        expect(bloc.state.restrictionState.activeMode, isNull);
        expect(bloc.state.sessionStartedAt, isNull);
        expect(bloc.state.pausedUntil, isNull);
      },
    );

    blocTest<BlockingBloc, BlockingState>(
      'resume clears pausedUntil and keeps active session',
      build: () {
        final now = DateTime.now().toUtc();
        final repository = FakeBlockingRepository(
          restrictionState: _restrictionState(
            activeModeId: 'mode-1',
            startedAt: now.subtract(const Duration(minutes: 5)),
            pausedUntil: now.add(const Duration(minutes: 5)),
          ),
        );
        return BlockingBloc(
          blockingRepository: repository,
          modesRepository: modesRepository,
          nfcLinkedChipsRepository: nfcRepository,
          qrLinkedCodesRepository: qrRepository,
          emergencyStopRepository: emergencyStopRepository,
          internetRequiredGuard: internetRequiredGuard,
        );
      },
      act: (bloc) async {
        bloc.add(const BlockingSyncRequested());
        await Future<void>.delayed(const Duration(milliseconds: 20));
        bloc.add(const BlockingResumeRequested());
      },
      verify: (bloc) {
        expect(bloc.state.restrictionState.activeMode?.modeId, 'mode-1');
        expect(bloc.state.pausedUntil, isNull);
      },
    );

    blocTest<BlockingBloc, BlockingState>(
      'pause limit exception is mapped to action error',
      build: () {
        final repository = FakeBlockingRepository(
          restrictionState: _restrictionState(activeModeId: 'mode-1', startedAt: DateTime.now().toUtc()),
        )..pauseError = const PauseLimitReachedError();
        return BlockingBloc(
          blockingRepository: repository,
          modesRepository: modesRepository,
          nfcLinkedChipsRepository: nfcRepository,
          qrLinkedCodesRepository: qrRepository,
          emergencyStopRepository: emergencyStopRepository,
          internetRequiredGuard: internetRequiredGuard,
        );
      },
      act: (bloc) async {
        bloc.add(const BlockingSyncRequested());
        await Future<void>.delayed(const Duration(milliseconds: 20));
        bloc.add(const BlockingQuickPauseRequested(Duration(minutes: 5)));
      },
      verify: (bloc) {
        expect(bloc.state.error, isA<PauseLimitReachedError>());
      },
    );

    blocTest<BlockingBloc, BlockingState>(
      'sync keeps activeMode null when mode lookup fails',
      setUp: () {
        when(() => modesRepository.getMode(any())).thenThrow(Exception('Mode not found'));
      },
      build: () {
        final repository = FakeBlockingRepository(
          restrictionState: _restrictionState(activeModeId: 'missing-mode', startedAt: DateTime.now().toUtc()),
        );
        return BlockingBloc(
          blockingRepository: repository,
          modesRepository: modesRepository,
          nfcLinkedChipsRepository: nfcRepository,
          qrLinkedCodesRepository: qrRepository,
          emergencyStopRepository: emergencyStopRepository,
          internetRequiredGuard: internetRequiredGuard,
        );
      },
      act: (bloc) => bloc.add(const BlockingSyncRequested()),
      verify: (bloc) {
        expect(bloc.state.activeMode, isNull);
      },
    );

    blocTest<BlockingBloc, BlockingState>(
      'start rejects nfc scenario when no linked chips configured',
      setUp: () {
        when(() => nfcRepository.hasLinkedChips()).thenAnswer((_) async => false);
      },
      build: () {
        final repository = FakeBlockingRepository(restrictionState: _restrictionState(activeModeId: null));
        return BlockingBloc(
          blockingRepository: repository,
          modesRepository: modesRepository,
          nfcLinkedChipsRepository: nfcRepository,
          qrLinkedCodesRepository: qrRepository,
          emergencyStopRepository: emergencyStopRepository,
          internetRequiredGuard: internetRequiredGuard,
        );
      },
      act: (bloc) => bloc.add(BlockingStartRequested(_startModeFor(ModeEndingPausingScenario.nfc))),
      verify: (bloc) {
        expect(bloc.state.error, isA<NfcStartConfigurationMissingError>());
      },
    );

    blocTest<BlockingBloc, BlockingState>(
      'start allows nfc scenario when at least one linked chip exists',
      build: () {
        final repository = FakeBlockingRepository(restrictionState: _restrictionState(activeModeId: null));
        when(
          () => modesRepository.getMode(any()),
        ).thenAnswer((_) async => _startModeFor(ModeEndingPausingScenario.nfc));
        return BlockingBloc(
          blockingRepository: repository,
          modesRepository: modesRepository,
          nfcLinkedChipsRepository: nfcRepository,
          qrLinkedCodesRepository: qrRepository,
          emergencyStopRepository: emergencyStopRepository,
          internetRequiredGuard: internetRequiredGuard,
        );
      },
      act: (bloc) => bloc.add(BlockingStartRequested(_startModeFor(ModeEndingPausingScenario.nfc))),
      verify: (bloc) {
        // Start succeeded — state has an active mode now.
        expect(bloc.state.restrictionState.activeMode, isNotNull);
      },
    );

    blocTest<BlockingBloc, BlockingState>(
      'start rejects qr scenario when no linked codes configured',
      setUp: () {
        when(() => qrRepository.hasLinkedCodes()).thenAnswer((_) async => false);
      },
      build: () {
        final repository = FakeBlockingRepository(restrictionState: _restrictionState(activeModeId: null));
        return BlockingBloc(
          blockingRepository: repository,
          modesRepository: modesRepository,
          nfcLinkedChipsRepository: nfcRepository,
          qrLinkedCodesRepository: qrRepository,
          emergencyStopRepository: emergencyStopRepository,
          internetRequiredGuard: internetRequiredGuard,
        );
      },
      act: (bloc) => bloc.add(BlockingStartRequested(_startModeFor(ModeEndingPausingScenario.qrCode))),
      verify: (bloc) {
        expect(bloc.state.error, isA<QrStartConfigurationMissingError>());
      },
    );

    blocTest<BlockingBloc, BlockingState>(
      'start allows qr scenario when at least one linked code exists',
      build: () {
        final repository = FakeBlockingRepository(restrictionState: _restrictionState(activeModeId: null));
        when(
          () => modesRepository.getMode(any()),
        ).thenAnswer((_) async => _startModeFor(ModeEndingPausingScenario.qrCode));
        return BlockingBloc(
          blockingRepository: repository,
          modesRepository: modesRepository,
          nfcLinkedChipsRepository: nfcRepository,
          qrLinkedCodesRepository: qrRepository,
          emergencyStopRepository: emergencyStopRepository,
          internetRequiredGuard: internetRequiredGuard,
        );
      },
      act: (bloc) => bloc.add(BlockingStartRequested(_startModeFor(ModeEndingPausingScenario.qrCode))),
      verify: (bloc) {
        expect(bloc.state.restrictionState.activeMode, isNotNull);
      },
    );

    blocTest<BlockingBloc, BlockingState>(
      'nfc scenario requires scan proof',
      setUp: () {
        when(() => modesRepository.getMode(any())).thenAnswer((_) async => _modeFor(ModeEndingPausingScenario.nfc));
      },
      build: () {
        final repository = FakeBlockingRepository(
          restrictionState: _restrictionState(activeModeId: 'mode-1', startedAt: DateTime.now().toUtc()),
        );
        return BlockingBloc(
          blockingRepository: repository,
          modesRepository: modesRepository,
          nfcLinkedChipsRepository: nfcRepository,
          qrLinkedCodesRepository: qrRepository,
          emergencyStopRepository: emergencyStopRepository,
          internetRequiredGuard: internetRequiredGuard,
        );
      },
      act: (bloc) async {
        bloc.add(const BlockingSyncRequested());
        await Future<void>.delayed(const Duration(milliseconds: 20));
        bloc.add(const BlockingQuickPauseRequested(Duration(minutes: 5)));
      },
      verify: (bloc) {
        expect(bloc.state.error, isA<ScenarioProofRequiredError>());
      },
    );

    blocTest<BlockingBloc, BlockingState>(
      'nfc scenario rejects unlinked chip',
      setUp: () {
        when(() => modesRepository.getMode(any())).thenAnswer((_) async => _modeFor(ModeEndingPausingScenario.nfc));
        when(() => nfcRepository.hasChip(chipIdentifier: any(named: 'chipIdentifier'))).thenAnswer((_) async => false);
      },
      build: () {
        final repository = FakeBlockingRepository(
          restrictionState: _restrictionState(activeModeId: 'mode-1', startedAt: DateTime.now().toUtc()),
        );
        return BlockingBloc(
          blockingRepository: repository,
          modesRepository: modesRepository,
          nfcLinkedChipsRepository: nfcRepository,
          qrLinkedCodesRepository: qrRepository,
          emergencyStopRepository: emergencyStopRepository,
          internetRequiredGuard: internetRequiredGuard,
        );
      },
      act: (bloc) async {
        bloc.add(const BlockingSyncRequested());
        await Future<void>.delayed(const Duration(milliseconds: 20));
        bloc.add(
          BlockingQuickPauseRequested(
            const Duration(minutes: 5),
            proof: NfcActionProof(chipIdentifier: NfcChipIdentifier.parse('a1b2')),
          ),
        );
      },
      verify: (bloc) {
        expect(bloc.state.error, isA<NfcChipNotLinkedError>());
      },
    );

    blocTest<BlockingBloc, BlockingState>(
      'nfc scenario accepts linked chip',
      setUp: () {
        when(() => modesRepository.getMode(any())).thenAnswer((_) async => _modeFor(ModeEndingPausingScenario.nfc));
      },
      build: () {
        final repository = FakeBlockingRepository(
          restrictionState: _restrictionState(activeModeId: 'mode-1', startedAt: DateTime.now().toUtc()),
        );
        return BlockingBloc(
          blockingRepository: repository,
          modesRepository: modesRepository,
          nfcLinkedChipsRepository: nfcRepository,
          qrLinkedCodesRepository: qrRepository,
          emergencyStopRepository: emergencyStopRepository,
          internetRequiredGuard: internetRequiredGuard,
        );
      },
      act: (bloc) async {
        bloc.add(const BlockingSyncRequested());
        await Future<void>.delayed(const Duration(milliseconds: 20));
        bloc.add(
          BlockingQuickPauseRequested(
            const Duration(minutes: 5),
            proof: NfcActionProof(chipIdentifier: NfcChipIdentifier.parse('a1b2')),
          ),
        );
      },
      verify: (bloc) {
        expect(bloc.state.pausedUntil, isNotNull);
      },
    );

    blocTest<BlockingBloc, BlockingState>(
      'qr scenario rejects invalid payload',
      setUp: () {
        when(() => modesRepository.getMode(any())).thenAnswer((_) async => _modeFor(ModeEndingPausingScenario.qrCode));
      },
      build: () {
        final repository = FakeBlockingRepository(
          restrictionState: _restrictionState(activeModeId: 'mode-1', startedAt: DateTime.now().toUtc()),
        );
        return BlockingBloc(
          blockingRepository: repository,
          modesRepository: modesRepository,
          nfcLinkedChipsRepository: nfcRepository,
          qrLinkedCodesRepository: qrRepository,
          emergencyStopRepository: emergencyStopRepository,
          internetRequiredGuard: internetRequiredGuard,
        );
      },
      act: (bloc) async {
        bloc.add(const BlockingSyncRequested());
        await Future<void>.delayed(const Duration(milliseconds: 20));
        bloc.add(const BlockingStopRequested(proof: QrActionProof(rawValue: 'bad-value')));
      },
      verify: (bloc) {
        expect(bloc.state.error, isA<QrCodeInvalidError>());
      },
    );

    blocTest<BlockingBloc, BlockingState>(
      'qr scenario rejects non-linked code',
      setUp: () {
        when(() => modesRepository.getMode(any())).thenAnswer((_) async => _modeFor(ModeEndingPausingScenario.qrCode));
        when(() => qrRepository.hasScanValue(scanValue: any(named: 'scanValue'))).thenAnswer((_) async => false);
      },
      build: () {
        final repository = FakeBlockingRepository(
          restrictionState: _restrictionState(activeModeId: 'mode-1', startedAt: DateTime.now().toUtc()),
        );
        return BlockingBloc(
          blockingRepository: repository,
          modesRepository: modesRepository,
          nfcLinkedChipsRepository: nfcRepository,
          qrLinkedCodesRepository: qrRepository,
          emergencyStopRepository: emergencyStopRepository,
          internetRequiredGuard: internetRequiredGuard,
        );
      },
      act: (bloc) async {
        bloc.add(const BlockingSyncRequested());
        await Future<void>.delayed(const Duration(milliseconds: 20));
        bloc.add(const BlockingStopRequested(proof: QrActionProof(rawValue: _validQrToken)));
      },
      verify: (bloc) {
        expect(bloc.state.error, isA<QrCodeNotLinkedError>());
      },
    );

    blocTest<BlockingBloc, BlockingState>(
      'qr scenario accepts linked code',
      setUp: () {
        when(() => modesRepository.getMode(any())).thenAnswer((_) async => _modeFor(ModeEndingPausingScenario.qrCode));
      },
      build: () {
        final repository = FakeBlockingRepository(
          restrictionState: _restrictionState(activeModeId: 'mode-1', startedAt: DateTime.now().toUtc()),
        );
        return BlockingBloc(
          blockingRepository: repository,
          modesRepository: modesRepository,
          nfcLinkedChipsRepository: nfcRepository,
          qrLinkedCodesRepository: qrRepository,
          emergencyStopRepository: emergencyStopRepository,
          internetRequiredGuard: internetRequiredGuard,
        );
      },
      act: (bloc) async {
        bloc.add(const BlockingSyncRequested());
        await Future<void>.delayed(const Duration(milliseconds: 20));
        bloc.add(const BlockingStopRequested(proof: QrActionProof(rawValue: _validQrToken)));
      },
      verify: (bloc) {
        // Stop succeeded — state has no active mode.
        expect(bloc.state.restrictionState.activeMode, isNull);
      },
    );
  });
}

// ---------------------------------------------------------------------------
// Stateful fake – kept because the bloc relies on mutating repository state
// between sync calls (getRestrictionSession returns different results after
// pause / stop / resume / start).
// ---------------------------------------------------------------------------

class FakeBlockingRepository implements BlockingRepository {
  FakeBlockingRepository({required this.restrictionState});

  RestrictionState restrictionState;
  BlockingActionError? pauseError;
  BlockingActionError? stopError;

  @override
  Stream<RestrictionLifecycleAction> get lifecycleActions => const Stream<RestrictionLifecycleAction>.empty();

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
    required RestrictionLifecycleReason reason,
    Duration? cooldownDuration,
  }) async {
    final error = stopError;
    if (error != null) {
      throw error;
    }
    this.restrictionState = _restrictionState(activeModeId: null);
  }

  @override
  Future<void> resumeBlocking() async {
    restrictionState = _restrictionState(
      activeModeId: restrictionState.activeMode?.modeId,
      startedAt: restrictionState.startedAt,
    );
  }

  @override
  Future<void> emergencyEndSession() async {
    restrictionState = _restrictionState(activeModeId: null);
  }

  @override
  Future<void> syncRestrictionLifecycleEvents() async {}

  @override
  void dispose() {}
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Mode _modeFor(ModeEndingPausingScenario scenario) {
  return makeMode(endingPausingScenario: scenario);
}

Mode _startModeFor(ModeEndingPausingScenario scenario) {
  return makeMode(
    endingPausingScenario: scenario,
    blockedAppIds: const ISetConst<AppIdentifier>(<AppIdentifier>{AppIdentifier('app.one')}),
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
            reason: RestrictionLifecycleReason.manual,
            occurredAt: startedAt,
          ),
        ];

  return makeRestrictionState(
    activeMode: activeModeId == null
        ? null
        : RestrictionMode(modeId: activeModeId, blockedAppIds: const <AppIdentifier>[]),
    activeModeSource: activeModeId == null ? RestrictionModeSource.none : RestrictionModeSource.manual,
    pausedUntil: pausedUntil,
    currentSessionEvents: currentSessionEvents,
  );
}
