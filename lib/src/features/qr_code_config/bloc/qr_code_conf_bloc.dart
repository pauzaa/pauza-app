import 'package:equatable/equatable.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/features/qr_code_config/data/qr_linked_codes_repository.dart';
import 'package:pauza/src/features/qr_code_config/model/qr_linked_code.dart';

part 'qr_code_conf_event.dart';
part 'qr_code_conf_state.dart';

class QrCodeConfBloc extends Bloc<QrCodeConfEvent, QrCodeConfState> {
  QrCodeConfBloc({required QrLinkedCodesRepository linkedCodesRepository})
    : _linkedCodesRepository = linkedCodesRepository,
      super(const QrCodeConfIdle(linkedCodes: IList.empty())) {
    on<QrCodeConfEvent>(
      (event, emit) => switch (event) {
        QrCodeLoadCodesRequested() => _onLoadCodesRequested(event, emit),
        QrCodeGenerateCodeRequested() => _onGenerateCodeRequested(event, emit),
        QrCodeRenameCodeRequested() => _onRenameCodeRequested(event, emit),
        QrCodeDeleteCodeRequested() => _onDeleteCodeRequested(event, emit),
      },
    );
  }

  final QrLinkedCodesRepository _linkedCodesRepository;

  Future<void> _onLoadCodesRequested(QrCodeLoadCodesRequested event, Emitter<QrCodeConfState> emit) async {
    try {
      emit(state.loading());
      await _onLoadCodes(emit);
    } on Object catch (error) {
      emit(state.setError(error));
    }
  }

  Future<void> _onGenerateCodeRequested(QrCodeGenerateCodeRequested event, Emitter<QrCodeConfState> emit) async {
    try {
      emit(state.loading());
      await _linkedCodesRepository.generateAndLinkCode();
      await _onLoadCodes(emit);
    } on Object catch (error) {
      emit(state.setError(error));
    }
  }

  Future<void> _onRenameCodeRequested(QrCodeRenameCodeRequested event, Emitter<QrCodeConfState> emit) async {
    try {
      emit(state.loading());
      await _linkedCodesRepository.renameCode(id: event.codeId, name: event.newName);
      await _onLoadCodes(emit);
    } on Object catch (error) {
      emit(state.setError(error));
    }
  }

  Future<void> _onDeleteCodeRequested(QrCodeDeleteCodeRequested event, Emitter<QrCodeConfState> emit) async {
    try {
      emit(state.loading());
      await _linkedCodesRepository.deleteCode(id: event.codeId);
      await _onLoadCodes(emit);
    } on Object catch (error) {
      emit(state.setError(error));
    }
  }

  Future<void> _onLoadCodes(Emitter<QrCodeConfState> emit) async {
    try {
      final linkedCodes = await _linkedCodesRepository.getLinkedCodes();
      emit(state.idle(linkedCodes));
    } on Object catch (error) {
      emit(state.setError(error));
    }
  }
}
