import 'dart:io';

import 'package:equatable/equatable.dart';
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
  }

  final ModesRepository _modesRepository;

  Future<void> _onModesRequested(ModesListRequested event, Emitter<ModesListState> emit) async {
    await _load(emit: emit);
  }

  Future<void> _onModesDeleteRequested(ModesDeleteRequested event, Emitter<ModesListState> emit) async {
    try {
      await _modesRepository.deleteMode(event.modeId);
      await _load(emit: emit);
    } on Object catch (error) {
      emit(state.setError(error));
    }
  }

  Future<void> _load({required Emitter<ModesListState> emit}) async {
    emit(state.loading());

    try {
      final platform = switch (Platform.isIOS) {
        true => PauzaPlatform.ios,
        false => PauzaPlatform.android,
      };
      final summaries = await _modesRepository.listSummaries(platform: platform);

      emit(state.copyWith(items: summaries, isLoading: false));
    } on Object catch (error) {
      emit(state.setError(error));
    }
  }
}
