import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/core/common/pauza_platform.dart';
import 'package:pauza/src/features/home/data/app_fuse_active_mode_storage.dart';
import 'package:pauza/src/features/home/data/pauza_screen_time_blocking_repository.dart';
import 'package:pauza/src/features/modes/common/data/modes_repository.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

part 'blocking_event.dart';
part 'blocking_state.dart';

class BlockingBloc extends Bloc<BlockingEvent, BlockingState> {
  BlockingBloc({
    required BlockingRepository blockingRepository,
    required ModesRepository modesRepository,
  }) : _blockingRepository = blockingRepository,
       _modesRepository = modesRepository,

       super(const BlockingState()) {
    on<BlockingSyncRequested>(_onSyncRequested);
    on<BlockingStartRequested>(_onStartRequested);
    on<BlockingStopRequested>(_onStopRequested);
  }

  final BlockingRepository _blockingRepository;
  final ModesRepository _modesRepository;

  Future<void> _onSyncRequested(BlockingSyncRequested event, Emitter<BlockingState> emit) async {
    try {
      final restrictedAppIds = await _blockingRepository.getRestrictedAppIds();
      if (restrictedAppIds.isEmpty) {
        emit(state.clearActiveModeId(isLoading: false));
        return;
      }

      final activeModeId = await _blockingRepository.getActiveModeId();
      if (activeModeId == null) {
        emit(state.clearActiveModeId(isLoading: false));
        return;
      } else {
        emit(state.setActiveModeId(activeModeId, isLoading: false));
      }
    } catch (error) {
      emit(state.setError(error));
    }
  }

  Future<void> _onStartRequested(BlockingStartRequested event, Emitter<BlockingState> emit) async {
    emit(state.loading());

    try {
      final mode = await _modesRepository.getMode(event.modeId);
      if (mode == null) {
        throw StateError('Mode not found');
      }
      if (!mode.isEnabled) {
        throw StateError('Selected mode is disabled');
      }

      final blockedAppIds = await _modesRepository.listBlockedAppIds(event.modeId, event.platform);
      if (blockedAppIds.isEmpty) {
        throw StateError('No blocked apps configured for this mode');
      }

      final shield = ShieldConfiguration(
        appGroupId: event.platform == PauzaPlatform.ios
            ? ActiveModeStorage.iosShieldAppGroupId
            : null,
        title: mode.textOnScreen,
        subtitle: mode.title,
      );

      await _blockingRepository.startBlocking(
        shield: shield,
        appIds: blockedAppIds,
        modeId: event.modeId,
      );

      emit(state.setActiveModeId(event.modeId, isLoading: false));
    } catch (error) {
      emit(state.setError(error));
    }
  }

  Future<void> _onStopRequested(BlockingStopRequested event, Emitter<BlockingState> emit) async {
    emit(state.loading());

    try {
      await _blockingRepository.stopBlocking();

      emit(state.clearActiveModeId(isLoading: false));
    } catch (error) {
      emit(state.setError(error));
    }
  }
}
