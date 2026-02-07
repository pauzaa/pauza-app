import 'package:equatable/equatable.dart';
import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/core/common/pauza_platform.dart';
import 'package:pauza/src/features/modes/common/data/modes_repository.dart';
import 'package:pauza/src/features/modes/common/model/mode_summary.dart';

part 'modes_event.dart';
part 'modes_state.dart';

class ModesListBloc extends Bloc<ModesListEvent, ModesListState> {
  ModesListBloc({required ModesRepository modesRepository})
    : _modesRepository = modesRepository,
      super(const ModesListState()) {
    on<ModesListRequested>(_onModesRequested);
    on<ModesDeleteRequested>(_onModesDeleteRequested);
    on<ModesSelectionRequested>(_onModesSelectionRequested);
  }

  final ModesRepository _modesRepository;

  Future<void> _onModesRequested(
    ModesListRequested event,
    Emitter<ModesListState> emit,
  ) async {
    await _load(emit: emit);
  }

  Future<void> _onModesDeleteRequested(
    ModesDeleteRequested event,
    Emitter<ModesListState> emit,
  ) async {
    try {
      await _modesRepository.deleteMode(event.modeId);
      await _load(emit: emit);
    } on Object catch (error) {
      emit(state.setError(error));
    }
  }

  void _onModesSelectionRequested(
    ModesSelectionRequested event,
    Emitter<ModesListState> emit,
  ) {
    if (state.selectedModeId == event.modeId) return;
    emit(state.copyWith(selectedModeId: event.modeId));
  }

  Future<void> _load({required Emitter<ModesListState> emit}) async {
    emit(state.loading());

    try {
      final platform = PauzaPlatform.current;

      final summaries = await _modesRepository.listSummaries(
        platform: platform,
      );
      final selectedModeId = _resolveSelectedModeId(
        items: summaries,
        selectedModeId: state.selectedModeId,
      );

      emit(
        state.copyWith(
          items: summaries,
          selectedModeId: selectedModeId,
          isLoading: false,
          clearError: true,
        ),
      );
    } on Object catch (error) {
      emit(state.setError(error));
    }
  }

  String? _resolveSelectedModeId({
    required List<ModeSummary> items,
    required String? selectedModeId,
  }) {
    if (items.isEmpty) return null;

    final stillExists = items.any(
      (summary) => summary.mode.id == selectedModeId,
    );
    if (stillExists) return selectedModeId;

    final currentSelected = state.selectedMode;
    if (currentSelected != null) {
      final updatedSelected = items.firstWhereOrNull(
        (summary) => summary.mode.id == currentSelected.mode.id,
      );
      if (updatedSelected != null) {
        return updatedSelected.mode.id;
      }
    }

    return items.first.mode.id;
  }
}
