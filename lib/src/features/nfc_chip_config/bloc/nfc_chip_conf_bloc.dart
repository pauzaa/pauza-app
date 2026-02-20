import 'package:equatable/equatable.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/features/nfc/model/nfc_card_dto.dart';
import 'package:pauza/src/features/nfc_chip_config/data/nfc_chip_config_error.dart';
import 'package:pauza/src/features/nfc_chip_config/data/nfc_linked_chips_repository.dart';
import 'package:pauza/src/features/nfc_chip_config/model/nfc_linked_chip.dart';

part 'nfc_chip_conf_event.dart';
part 'nfc_chip_conf_state.dart';

class NfcChipConfBloc extends Bloc<NfcChipConfEvent, NfcChipConfState> {
  NfcChipConfBloc({required NfcLinkedChipsRepository linkedChipsRepository})
    : _linkedChipsRepository = linkedChipsRepository,
      super(const NfcChipConfIdle(linkedChips: IList.empty())) {
    on<NfcChipConfEvent>(
      (event, emit) => switch (event) {
        NfcChipLoadCardsRequested() => _onLoadCardsRequested(event, emit),
        NfcChipDeleteCardRequested() => _onDeleteCardRequested(event, emit),
        NfcChipLinkCardRequested() => _onLinkCardRequested(event, emit),
        NfcChipRenameCardRequested() => _onRenameCardRequested(event, emit),
      },
    );
  }

  final NfcLinkedChipsRepository _linkedChipsRepository;

  Future<void> _onLoadCardsRequested(
    NfcChipLoadCardsRequested event,
    Emitter<NfcChipConfState> emit,
  ) async {
    try {
      emit(state.loading());
      await _onLoadCards(emit);
    } on Object catch (error) {
      emit(state.setError(error));
    }
  }

  Future<void> _onLoadCards(Emitter<NfcChipConfState> emit) async {
    try {
      final linkedChips = await _linkedChipsRepository.getLinkedChips();
      emit(state.idle(linkedChips));
    } on Object catch (error) {
      emit(state.setError(error));
    }
  }

  Future<void> _onDeleteCardRequested(
    NfcChipDeleteCardRequested event,
    Emitter<NfcChipConfState> emit,
  ) async {
    try {
      emit(state.loading());
      await _linkedChipsRepository.deleteChip(id: event.cardId);
      await _onLoadCards(emit);
    } on Object catch (error) {
      emit(state.setError(error));
    }
  }

  Future<void> _onLinkCardRequested(
    NfcChipLinkCardRequested event,
    Emitter<NfcChipConfState> emit,
  ) async {
    try {
      emit(state.loading());
      final uidHex = event.card.uidHex;
      if (uidHex == null || uidHex.isEmpty) {
        throw const NfcChipConfigMissingIdentifierError();
      }
      await _linkedChipsRepository.linkChipIfAbsent(chipIdentifier: uidHex);
      await _onLoadCards(emit);
    } on Object catch (error) {
      emit(state.setError(error));
    }
  }

  Future<void> _onRenameCardRequested(
    NfcChipRenameCardRequested event,
    Emitter<NfcChipConfState> emit,
  ) async {
    try {
      emit(state.loading());
      await _linkedChipsRepository.renameChip(
        id: event.cardId,
        name: event.newName,
      );
      await _onLoadCards(emit);
    } on Object catch (error) {
      emit(state.setError(error));
    }
  }
}
