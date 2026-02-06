import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/core/common/pauza_constants.dart';
import 'package:pauza/src/core/common/pauza_platform.dart';
import 'package:pauza/src/features/blocking/data/active_mode_storage.dart';
import 'package:pauza/src/features/blocking/data/blocking_repository.dart';
import 'package:pauza/src/features/modes/data/modes_repository.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

part 'blocking_event.dart';
part 'blocking_state.dart';

class BlockingBloc extends Bloc<BlockingEvent, BlockingState> {
  BlockingBloc({
    required BlockingRepository blockingRepository,
    required ModesRepository modesRepository,
    required ActiveModeStorage activeModeStorage,
  }) : _blockingRepository = blockingRepository,
       _modesRepository = modesRepository,
       _activeModeStorage = activeModeStorage,
       super(const BlockingState()) {
    on<BlockingSyncRequested>(_onSyncRequested);
    on<BlockingStartRequested>(_onStartRequested);
    on<BlockingStopRequested>(_onStopRequested);
  }

  final BlockingRepository _blockingRepository;
  final ModesRepository _modesRepository;
  final ActiveModeStorage _activeModeStorage;

  Future<void> _onSyncRequested(
    BlockingSyncRequested event,
    Emitter<BlockingState> emit,
  ) async {
    try {
      final restrictedAppIds = await _blockingRepository.getRestrictedAppIds();
      if (restrictedAppIds.isEmpty) {
        await _activeModeStorage.clearActiveModeId();
        emit(
          state.copyWith(
            status: BlockingStatus.idle,
            clearActiveModeId: true,
            clearError: true,
          ),
        );
        return;
      }

      final activeModeId = await _activeModeStorage.readActiveModeId();
      emit(
        state.copyWith(
          status: BlockingStatus.active,
          activeModeId: activeModeId,
          clearError: true,
        ),
      );
    } on Object catch (error) {
      emit(
        state.copyWith(status: BlockingStatus.failure, errorMessage: '$error'),
      );
    }
  }

  Future<void> _onStartRequested(
    BlockingStartRequested event,
    Emitter<BlockingState> emit,
  ) async {
    emit(state.copyWith(status: BlockingStatus.starting, clearError: true));

    try {
      final mode = await _modesRepository.getMode(event.modeId);
      if (mode == null) {
        throw StateError('Mode not found');
      }
      if (!mode.isEnabled) {
        throw StateError('Selected mode is disabled');
      }

      final blockedAppIds = await _modesRepository.listBlockedAppIds(
        event.modeId,
        event.platform,
      );
      if (blockedAppIds.isEmpty) {
        throw StateError('No blocked apps configured for this mode');
      }

      final shield = ShieldConfiguration(
        appGroupId: event.platform == PauzaPlatform.ios
            ? PauzaConstants.iosShieldAppGroupId
            : null,
        title: mode.textOnScreen,
        subtitle: mode.title,
      );

      await _blockingRepository.startBlocking(
        shield: shield,
        appIds: blockedAppIds,
      );
      await _activeModeStorage.writeActiveModeId(event.modeId);

      emit(
        state.copyWith(
          status: BlockingStatus.active,
          activeModeId: event.modeId,
          clearError: true,
        ),
      );
    } on Object catch (error) {
      emit(
        state.copyWith(status: BlockingStatus.failure, errorMessage: '$error'),
      );
    }
  }

  Future<void> _onStopRequested(
    BlockingStopRequested event,
    Emitter<BlockingState> emit,
  ) async {
    emit(state.copyWith(status: BlockingStatus.stopping, clearError: true));

    try {
      await _blockingRepository.stopBlocking();
      await _activeModeStorage.clearActiveModeId();

      emit(
        state.copyWith(
          status: BlockingStatus.idle,
          clearActiveModeId: true,
          clearError: true,
        ),
      );
    } on Object catch (error) {
      emit(
        state.copyWith(status: BlockingStatus.failure, errorMessage: '$error'),
      );
    }
  }
}
