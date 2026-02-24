import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/features/home/data/pauza_blocking_repository.dart';
import 'package:pauza/src/features/home/model/blocking_action_error.dart';
import 'package:pauza/src/features/home/model/blocking_action_proof.dart';
import 'package:pauza/src/features/modes/common/data/modes_repository.dart';
import 'package:pauza/src/features/modes/common/model/mode.dart';
import 'package:pauza/src/features/modes/common/model/mode_ending_pausing_scenario.dart';
import 'package:pauza/src/features/nfc_chip_config/data/nfc_linked_chips_repository.dart';
import 'package:pauza/src/features/qr_code_config/data/qr_linked_codes_repository.dart';
import 'package:pauza/src/features/qr_code_config/model/qr_unlock_token.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

part 'blocking_event.dart';
part 'blocking_state.dart';

class BlockingBloc extends Bloc<BlockingEvent, BlockingState> {
  BlockingBloc({
    required BlockingRepository blockingRepository,
    required ModesRepository modesRepository,
    required NfcLinkedChipsRepository nfcLinkedChipsRepository,
    required QrLinkedCodesRepository qrLinkedCodesRepository,
  }) : _blockingRepository = blockingRepository,
       _modesRepository = modesRepository,
       _nfcLinkedChipsRepository = nfcLinkedChipsRepository,
       _qrLinkedCodesRepository = qrLinkedCodesRepository,
       super(const BlockingState.initial()) {
    on<BlockingSyncRequested>(_onSyncRequested);
    on<BlockingStartRequested>(_onStartRequested);
    on<BlockingStopRequested>(_onStopRequested);
    on<BlockingQuickPauseRequested>(_onQuickPauseRequested);
    on<BlockingResumeRequested>(_onResumeRequested);
  }

  final BlockingRepository _blockingRepository;
  final ModesRepository _modesRepository;
  final NfcLinkedChipsRepository _nfcLinkedChipsRepository;
  final QrLinkedCodesRepository _qrLinkedCodesRepository;
  Timer? _syncTimer;

  @override
  Future<void> close() {
    _syncTimer?.cancel();
    _syncTimer = null;
    return super.close();
  }

  Future<void> _onSyncRequested(BlockingSyncRequested event, Emitter<BlockingState> emit) async {
    try {
      await _blockingRepository.syncRestrictionLifecycleEvents();
      await _syncSessionState(emit: emit);
    } catch (error) {
      emit(state.setError(error));
    }
  }

  Future<void> _onStartRequested(BlockingStartRequested event, Emitter<BlockingState> emit) async {
    try {
      emit(state.loading());

      final blockedAppIds = event.mode.blockedAppIds;
      if (blockedAppIds.isEmpty) {
        throw StateError('No blocked apps configured for this mode');
      }

      final shield = ShieldConfiguration(title: event.mode.textOnScreen, subtitle: event.mode.title);

      await _blockingRepository.startBlocking(mode: event.mode, shield: shield);
      await _syncSessionState(emit: emit);
    } catch (error) {
      emit(state.setError(error));
    }
  }

  Future<void> _onStopRequested(BlockingStopRequested event, Emitter<BlockingState> emit) async {
    try {
      emit(state.loading());
      await _validateScenarioProof(mode: state.activeMode, proof: event.proof);
      await _blockingRepository.stopBlocking(mode: state.activeMode, restrictionState: state.restrictionState);
      await _syncSessionState(emit: emit);
    } catch (error) {
      emit(state.setError(error));
    }
  }

  Future<void> _onQuickPauseRequested(BlockingQuickPauseRequested event, Emitter<BlockingState> emit) async {
    try {
      emit(state.loading());
      await _validateScenarioProof(mode: state.activeMode, proof: event.proof);
      await _blockingRepository.pauseBlocking(
        event.duration,
        mode: state.activeMode,
        restrictionState: state.restrictionState,
      );
      await _syncSessionState(emit: emit);
    } catch (error) {
      emit(state.setError(error));
    }
  }

  Future<void> _onResumeRequested(BlockingResumeRequested event, Emitter<BlockingState> emit) async {
    try {
      emit(state.loading());
      await _blockingRepository.resumeBlocking();
      await _syncSessionState(emit: emit);
    } catch (error) {
      emit(state.setError(error));
    }
  }

  Future<void> _syncSessionState({required Emitter<BlockingState> emit}) async {
    final restrictionSession = await _blockingRepository.getRestrictionSession();
    final activeMode = await _resolveActiveMode(restrictionState: restrictionSession);
    emit(state.setSessionState(restrictionState: restrictionSession, activeMode: activeMode, isLoading: false));
    if (state.pauseRemainingDuration case final pauseRemainingDuration? when restrictionSession.isPausedNow) {
      _syncTimer = Timer(pauseRemainingDuration, () {
        if (isClosed) return;
        add(const BlockingResumeRequested());
      });
    }
  }

  Future<Mode?> _resolveActiveMode({required RestrictionState restrictionState}) async {
    final modeId = restrictionState.activeMode?.modeId;
    if (modeId == null || modeId.isEmpty) {
      return null;
    }

    return await _modesRepository.getMode(modeId);
  }

  Future<void> _validateScenarioProof({required Mode? mode, required BlockingActionProof? proof}) async {
    if (mode == null) {
      throw const ActiveModeUnavailableError();
    }

    switch (mode.endingPausingScenario) {
      case ModeEndingPausingScenario.manual:
        return;
      case ModeEndingPausingScenario.nfc:
        return await _validateNfcProof(proof);
      case ModeEndingPausingScenario.qrCode:
        return await _validateQrProof(proof);
    }
  }

  Future<void> _validateNfcProof(BlockingActionProof? proof) async {
    if (proof is! NfcActionProof) {
      throw const ScenarioProofRequiredError();
    }

    final chipIdentifier = proof.chipIdentifier;
    if (chipIdentifier == null) {
      throw const NfcScanMissingIdentifierError();
    }

    final hasChip = await _nfcLinkedChipsRepository.hasChip(chipIdentifier: chipIdentifier);
    if (!hasChip) {
      throw const NfcChipNotLinkedError();
    }
  }

  Future<void> _validateQrProof(BlockingActionProof? proof) async {
    if (proof is! QrActionProof) {
      throw const ScenarioProofRequiredError();
    }

    final token = QrUnlockToken.tryParse(proof.rawValue);
    if (token == null) {
      throw const QrCodeInvalidError();
    }

    final hasCode = await _qrLinkedCodesRepository.hasScanValue(scanValue: token.normalized);
    if (!hasCode) {
      throw const QrCodeNotLinkedError();
    }
  }
}
