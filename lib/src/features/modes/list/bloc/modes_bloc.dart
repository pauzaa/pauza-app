import 'dart:async';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/core/common/pauza_platform.dart';
import 'package:pauza/src/features/modes/common/data/modes_repository.dart';
import 'package:pauza/src/features/modes/common/model/models.dart';

part 'modes_event.dart';
part 'modes_state.dart';

class ModesListBloc extends Bloc<ModesListEvent, ModesListState> {
  ModesListBloc({required ModesRepository modesRepository})
    : _modesRepository = modesRepository,
      super(const ModesListState()) {
    _modesSubscription = _modesRepository.watchModes().listen((_) => add(const ModesListUpdated()), onError: (_) {});
    on<ModesListRequested>(_onModesRequested);
    on<ModesDeleteRequested>(_onModesDeleteRequested);
    on<ModesSelectionRequested>(_onModesSelectionRequested);
    on<ModesListUpdated>(_onModesUpdated);
  }

  final ModesRepository _modesRepository;
  late final StreamSubscription<void> _modesSubscription;

  Future<void> _onModesRequested(ModesListRequested event, Emitter<ModesListState> emit) async {
    await _load(emit: emit);
  }

  Future<void> _onModesDeleteRequested(ModesDeleteRequested event, Emitter<ModesListState> emit) async {
    try {
      emit(state.loading());
      await _modesRepository.deleteMode(event.modeId);
      await _load(emit: emit);
    } on Object catch (error) {
      emit(state.setError(error));
    }
  }

  void _onModesSelectionRequested(ModesSelectionRequested event, Emitter<ModesListState> emit) {
    if (state.selectedModeId == event.modeId) return;
    emit(state.copyWith(selectedModeId: event.modeId));
  }

  Future<void> _onModesUpdated(ModesListUpdated event, Emitter<ModesListState> emit) async {
    await _load(emit: emit);
  }

  Future<void> _load({required Emitter<ModesListState> emit}) async {
    emit(state.loading());

    try {
      final modes = await _modesRepository.getModes();

      emit(
        state.copyWith(items: modes, isLoading: false, selectedModeId: state.selectedModeId ?? modes.firstOrNull?.id),
      );
    } on Object catch (error) {
      emit(state.setError(error));
    }
  }

  @override
  Future<void> close() async {
    await _modesSubscription.cancel();
    await super.close();
  }
}
