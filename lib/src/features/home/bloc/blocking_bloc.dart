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

      super(const BlockingState()) {
    on<BlockingSyncRequested>(_onSyncRequested);
    on<BlockingStartRequested>(_onStartRequested);
    on<BlockingStopRequested>(_onStopRequested);
  }

  final BlockingRepository _blockingRepository;

  Future<void> _onSyncRequested(BlockingSyncRequested event, Emitter<BlockingState> emit) async {
    try {
      final restrictionSession = await _blockingRepository.getRestrictionSession();

      if (restrictionSession.activeMode?.modeId  case final activeModeId?) {
        emit(state.setActiveModeId(activeModeId, isLoading: false));
        return;
      } else {
        emit(state.clearActiveModeId(isLoading: false));
      }
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

      final shield = ShieldConfiguration(
        title: event.mode.textOnScreen,
        subtitle: event.mode.title,
      );

      await _blockingRepository.startBlocking(mode: event.mode, shield: shield);

      emit(state.setActiveModeId(event.mode.id, isLoading: false));
    } catch (error) {
      emit(state.setError(error));
    }
  }

  Future<void> _onStopRequested(BlockingStopRequested event, Emitter<BlockingState> emit) async {
    try {
      emit(state.loading());

      await _blockingRepository.stopBlocking();

      emit(state.clearActiveModeId(isLoading: false));
    } catch (error) {
      emit(state.setError(error));
    }
  }
}
