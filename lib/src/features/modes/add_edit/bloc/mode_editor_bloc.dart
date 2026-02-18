import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/features/modes/common/data/modes_repository.dart';
import 'package:pauza/src/features/modes/common/model/mode_upsert.dart';

part 'mode_editor_event.dart';
part 'mode_editor_state.dart';

class ModeEditorBloc extends Bloc<ModeEditorEvent, ModeEditorState> {
  ModeEditorBloc({required ModesRepository modesRepository})
    : _modesRepository = modesRepository,
      super(const ModeEditorInitial()) {
    on<ModeEditorLoadRequested>(_onLoadRequested);
    on<ModeEditorSaveRequested>(_onSaveRequested);
    on<ModeEditorDeleteRequested>(_onDeleteRequested);
  }

  final ModesRepository _modesRepository;

  Future<void> _onLoadRequested(
    ModeEditorLoadRequested event,
    Emitter<ModeEditorState> emit,
  ) async {
    emit(const ModeEditorLoading());

    if (event.modeId == null) {
      emit(
        const ModeEditorReady(modeId: null, request: ModeUpsertDTO.initial()),
      );
      return;
    }

    try {
      final mode = await _modesRepository.getMode(event.modeId!);

      emit(
        ModeEditorReady(
          modeId: mode.id,
          request: ModeUpsertDTO(
            title: mode.title,
            textOnScreen: mode.textOnScreen,
            description: mode.description,
            allowedPausesCount: mode.allowedPausesCount,
            icon: mode.icon,
            blockedAppIds: mode.blockedAppIds,
            schedule: mode.schedule,
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
        await _modesRepository.createMode(event.request);
      } else {
        await _modesRepository.updateMode(
          modeId: event.modeId!,
          request: event.request,
        );
      }
      emit(ModeEditorSaveSuccess(modeId: event.modeId, request: event.request));
    } on Object catch (error) {
      emit(ModeEditorFailure(error));
    }
  }

  Future<void> _onDeleteRequested(
    ModeEditorDeleteRequested event,
    Emitter<ModeEditorState> emit,
  ) async {
    emit(const ModeEditorLoading());

    final modeId = event.modeId;
    if (modeId == null || modeId.isEmpty) {
      emit(ModeEditorFailure(StateError('Missing mode id for delete.')));
      return;
    }

    try {
      await _modesRepository.deleteMode(modeId);
      emit(ModeEditorDeleteSuccess(modeId: modeId));
    } on Object catch (error) {
      emit(ModeEditorFailure(error));
    }
  }
}
