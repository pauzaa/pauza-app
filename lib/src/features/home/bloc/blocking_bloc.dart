import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/features/home/data/pauza_blocking_repository.dart';
import 'package:pauza/src/features/modes/common/model/mode.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

part 'blocking_event.dart';
part 'blocking_state.dart';

class BlockingBloc extends Bloc<BlockingEvent, BlockingState> {
  BlockingBloc({required BlockingRepository blockingRepository})
    : _blockingRepository = blockingRepository,
      super(const BlockingState.initial()) {
    on<BlockingSyncRequested>(_onSyncRequested);
    on<BlockingStartRequested>(_onStartRequested);
    on<BlockingStopRequested>(_onStopRequested);
    on<BlockingQuickPauseRequested>(_onQuickPauseRequested);
    on<BlockingResumeRequested>(_onResumeRequested);
  }

  final BlockingRepository _blockingRepository;
  Timer? _syncTimer;

  @override
  Future<void> close() {
    _syncTimer?.cancel();
    _syncTimer = null;
    return super.close();
  }

  Future<void> _onSyncRequested(
    BlockingSyncRequested event,
    Emitter<BlockingState> emit,
  ) async {
    try {
      await _blockingRepository.syncRestrictionLifecycleEvents();
      await _syncSessionState(emit: emit);
    } catch (error) {
      emit(state.setError(error));
    }
  }

  Future<void> _onStartRequested(
    BlockingStartRequested event,
    Emitter<BlockingState> emit,
  ) async {
    try {
      emit(state.loading());

      final blockedAppIds = event.mode.blockedAppIds;
      if (blockedAppIds.isEmpty) {
        throw StateError('No blocked apps configured for this mode');
      }

      final shield = ShieldConfiguration(
        title: event.mode.textOnScreen,
        subtitle: event.mode.title,
      );

      await _blockingRepository.startBlocking(mode: event.mode, shield: shield);
      await _syncSessionState(emit: emit);
    } catch (error) {
      emit(state.setError(error));
    }
  }

  Future<void> _onStopRequested(
    BlockingStopRequested event,
    Emitter<BlockingState> emit,
  ) async {
    try {
      emit(state.loading());
      await _blockingRepository.stopBlocking();
      await _syncSessionState(emit: emit);
    } catch (error) {
      emit(state.setError(error));
    }
  }

  Future<void> _onQuickPauseRequested(
    BlockingQuickPauseRequested event,
    Emitter<BlockingState> emit,
  ) async {
    try {
      emit(state.loading());
      await _blockingRepository.pauseBlocking(event.duration);
      await _syncSessionState(emit: emit);
    } catch (error) {
      emit(state.setError(error));
    }
  }

  Future<void> _onResumeRequested(
    BlockingResumeRequested event,
    Emitter<BlockingState> emit,
  ) async {
    try {
      emit(state.loading());
      await _blockingRepository.resumeBlocking();
      await _syncSessionState(emit: emit);
    } catch (error) {
      emit(state.setError(error));
    }
  }

  Future<void> _syncSessionState({required Emitter<BlockingState> emit}) async {
    final restrictionSession = await _blockingRepository
        .getRestrictionSession();
    emit(
      state.setSessionState(
        restrictionState: restrictionSession,
        isLoading: false,
      ),
    );
    if (state.pauseRemainingDuration case final pauseRemainingDuration?
        when restrictionSession.isPausedNow) {
      _syncTimer = Timer(pauseRemainingDuration, () {
        if (isClosed) return;
        add(const BlockingResumeRequested());
      });
    }
  }
}
