import 'package:equatable/equatable.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/core/common/pauza_platform.dart';
import 'package:pauza/src/features/modes/common/data/modes_repository.dart';
import 'package:pauza/src/features/modes/common/model/mode_upsert_request.dart';

part 'mode_editor_event.dart';
part 'mode_editor_state.dart';

class ModeEditorBloc extends Bloc<ModeEditorEvent, ModeEditorState> {
  ModeEditorBloc({required ModesRepository modesRepository})
    : _modesRepository = modesRepository,
      super(const ModeEditorInitial()) {
    on<ModeEditorLoadRequested>(_onLoadRequested);
    on<ModeEditorSaveRequested>(_onSaveRequested);
  }

  final ModesRepository _modesRepository;

  Future<void> _onLoadRequested(
    ModeEditorLoadRequested event,
    Emitter<ModeEditorState> emit,
  ) async {
    emit(const ModeEditorLoading());

    if (event.modeId == null) {
      emit(const ModeEditorReady(modeId: null, request: ModeUpsertDTO.empty));
      return;
    }

    try {
      final mode = await _modesRepository.getMode(event.modeId!);
      if (mode == null) {
        emit(ModeEditorFailure(StateError('Mode not found: ${event.modeId}')));
        return;
      }

      final blockedAppIds = await _modesRepository.listBlockedAppIds(
        mode.id,
        PauzaPlatform.current,
      );

      emit(
        ModeEditorReady(
          modeId: mode.id,
          request: ModeUpsertDTO(
            title: mode.title,
            textOnScreen: mode.textOnScreen,
            description: mode.description,
            allowedPausesCount: mode.allowedPausesCount,
            isEnabled: mode.isEnabled,
            blockedAppIds: blockedAppIds.toISet(),
          ),
        ),
      );
    } on Object catch (error) {
      emit(ModeEditorFailure(error));
    }
  }

  Future<void> _onSaveRequested(
    ModeEditorSaveRequested event,
    Emitter<ModeEditorState> emit,
  ) async {
    emit(const ModeEditorLoading());

    try {
      if (event.modeId == null) {
        await _modesRepository.createMode(request: event.request, platform: PauzaPlatform.current);
      } else {
        await _modesRepository.updateMode(
          modeId: event.modeId!,
          request: event.request,
          platform: PauzaPlatform.current,
        );
      }
      emit(ModeEditorSaveSuccess(modeId: event.modeId, request: event.request));
    } on Object catch (error) {
      emit(ModeEditorFailure(error));
    }
  }
}
