import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/core/common/pauza_platform.dart';
import 'package:pauza/src/features/modes/data/modes_repository.dart';
import 'package:pauza/src/features/modes/model/mode_summary.dart';

part 'modes_event.dart';
part 'modes_state.dart';

class ModesBloc extends Bloc<ModesEvent, ModesState> {
  ModesBloc({required ModesRepository modesRepository})
    : _modesRepository = modesRepository,
      super(const ModesState()) {
    on<ModesRequested>(_onModesRequested);
    on<ModesRefreshed>(_onModesRefreshed);
    on<ModesSelectionChanged>(_onModesSelectionChanged);
    on<ModesDeleteRequested>(_onModesDeleteRequested);
  }

  final ModesRepository _modesRepository;

  Future<void> _onModesRequested(
    ModesRequested event,
    Emitter<ModesState> emit,
  ) async {
    await _load(platform: event.platform, emit: emit);
  }

  Future<void> _onModesRefreshed(
    ModesRefreshed event,
    Emitter<ModesState> emit,
  ) async {
    await _load(platform: state.platform, emit: emit);
  }

  Future<void> _onModesSelectionChanged(
    ModesSelectionChanged event,
    Emitter<ModesState> emit,
  ) async {
    final exists = state.items.any(
      (summary) => summary.mode.id == event.modeId,
    );
    if (!exists) {
      return;
    }

    emit(state.copyWith(selectedModeId: event.modeId));
  }

  Future<void> _onModesDeleteRequested(
    ModesDeleteRequested event,
    Emitter<ModesState> emit,
  ) async {
    try {
      await _modesRepository.deleteMode(event.modeId);
      await _load(platform: state.platform, emit: emit);
    } on Object catch (error) {
      emit(state.copyWith(status: ModesStatus.failure, errorMessage: '$error'));
    }
  }

  Future<void> _load({
    required PauzaPlatform platform,
    required Emitter<ModesState> emit,
  }) async {
    emit(
      state.copyWith(
        status: ModesStatus.loading,
        platform: platform,
        clearError: true,
      ),
    );

    try {
      final summaries = await _modesRepository.listSummaries(
        platform: platform,
      );
      final selectedModeId = _resolveSelectedModeId(
        summaries: summaries,
        previousSelectedModeId: state.selectedModeId,
      );

      emit(
        state.copyWith(
          status: ModesStatus.ready,
          items: summaries,
          selectedModeId: selectedModeId,
          clearSelectedModeId: selectedModeId == null,
          clearError: true,
        ),
      );
    } on Object catch (error) {
      emit(state.copyWith(status: ModesStatus.failure, errorMessage: '$error'));
    }
  }

  String? _resolveSelectedModeId({
    required List<ModeSummary> summaries,
    required String? previousSelectedModeId,
  }) {
    if (summaries.isEmpty) {
      return null;
    }

    final selected = summaries.firstWhereOrNull(
      (summary) => summary.mode.id == previousSelectedModeId,
    );
    if (selected != null) {
      return selected.mode.id;
    }

    final enabled = summaries.firstWhereOrNull(
      (summary) => summary.mode.isEnabled,
    );
    return enabled?.mode.id ?? summaries.first.mode.id;
  }
}
