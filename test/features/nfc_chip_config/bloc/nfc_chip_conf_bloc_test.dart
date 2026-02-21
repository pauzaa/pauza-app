import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/features/nfc/model/nfc_card_dto.dart';
import 'package:pauza/src/features/nfc/model/nfc_chip_identifier.dart';
import 'package:pauza/src/features/nfc/model/nfc_ndef_record_dto.dart';
import 'package:pauza/src/features/nfc/model/nfc_tag_tech.dart';
import 'package:pauza/src/features/nfc_chip_config/bloc/nfc_chip_conf_bloc.dart';
import 'package:pauza/src/features/nfc_chip_config/data/nfc_chip_config_error.dart';
import 'package:pauza/src/features/nfc_chip_config/data/nfc_linked_chips_repository.dart';
import 'package:pauza/src/features/nfc_chip_config/model/nfc_linked_chip.dart';

void main() {
  group('NfcChipConfBloc', () {
    test('emits already linked error when repository reports duplicate chip', () async {
      final repository = _FakeNfcLinkedChipsRepository(linkChipIfAbsentResult: false);
      final bloc = NfcChipConfBloc(linkedChipsRepository: repository);
      addTearDown(bloc.close);

      final emitted = <NfcChipConfState>[];
      final subscription = bloc.stream.listen(emitted.add);
      addTearDown(subscription.cancel);

      bloc.add(NfcChipLinkCardRequested(card: _card(uidHex: NfcChipIdentifier.parse('a1b2'))));
      await Future<void>.delayed(const Duration(milliseconds: 1));

      expect(emitted, hasLength(2));
      expect(emitted[0], const NfcChipConfLoading(linkedChips: IList.empty()));
      expect(emitted[1], const NfcChipConfError(error: NfcChipConfigAlreadyLinkedError(), linkedChips: IList.empty()));
    });

    test('emits missing identifier error when scanned card uid is null', () async {
      final repository = _FakeNfcLinkedChipsRepository();
      final bloc = NfcChipConfBloc(linkedChipsRepository: repository);
      addTearDown(bloc.close);

      final emitted = <NfcChipConfState>[];
      final subscription = bloc.stream.listen(emitted.add);
      addTearDown(subscription.cancel);

      bloc.add(NfcChipLinkCardRequested(card: _card(uidHex: null)));
      await Future<void>.delayed(const Duration(milliseconds: 1));

      expect(emitted, hasLength(2));
      expect(emitted[0], const NfcChipConfLoading(linkedChips: IList.empty()));
      expect(
        emitted[1],
        const NfcChipConfError(error: NfcChipConfigMissingIdentifierError(), linkedChips: IList.empty()),
      );
    });

    test('retains linked chips across loading and error states', () async {
      final initialChip = _chip(id: 'chip-1', name: 'Desk Tag');
      final repository = _FakeNfcLinkedChipsRepository(
        getLinkedChipsResult: IList([initialChip]),
        renameError: StateError('rename failed'),
      );
      final bloc = NfcChipConfBloc(linkedChipsRepository: repository);
      addTearDown(bloc.close);

      final emitted = <NfcChipConfState>[];
      final subscription = bloc.stream.listen(emitted.add);
      addTearDown(subscription.cancel);

      bloc.add(const NfcChipLoadCardsRequested());
      await Future<void>.delayed(const Duration(milliseconds: 1));

      bloc.add(const NfcChipRenameCardRequested(cardId: 'chip-1', newName: 'Desk'));
      await Future<void>.delayed(const Duration(milliseconds: 1));

      expect(emitted, hasLength(4));
      expect(emitted[0], const NfcChipConfLoading(linkedChips: IList.empty()));
      expect(emitted[1], NfcChipConfIdle(linkedChips: IList([initialChip])));
      expect(emitted[2], NfcChipConfLoading(linkedChips: IList([initialChip])));
      expect(emitted[3], isA<NfcChipConfError>());
      final errorState = emitted[3] as NfcChipConfError;
      expect(errorState.error, isA<StateError>());
      expect(errorState.linkedChips, IList([initialChip]));
    });
  });
}

NfcLinkedChip _chip({required String id, required String name}) {
  final timestamp = DateTime.utc(2026);
  return NfcLinkedChip(id: id, chipIdentifier: 'chip-$id', name: name, createdAt: timestamp, updatedAt: timestamp);
}

NfcCardDto _card({required NfcChipIdentifier? uidHex}) {
  return NfcCardDto(
    id: 'card',
    detectedAt: DateTime.utc(2026),
    uidHex: uidHex,
    techTypes: IList(const <NfcTagTech>[NfcTagTech.nfcA]),
    isNdefFormatted: false,
    ndefRecords: IList(const <NfcNdefRecordDto>[]),
    rawSnapshot: IMap(const <String, Object?>{}),
  );
}

final class _FakeNfcLinkedChipsRepository implements NfcLinkedChipsRepository {
  _FakeNfcLinkedChipsRepository({
    this.getLinkedChipsResult = const IList.empty(),
    this.linkChipIfAbsentResult = true,
    this.renameError,
  });

  final IList<NfcLinkedChip> getLinkedChipsResult;
  final bool linkChipIfAbsentResult;
  final Object? renameError;

  @override
  Future<void> deleteChip({required String id}) async {}

  @override
  Future<IList<NfcLinkedChip>> getLinkedChips() async => getLinkedChipsResult;

  @override
  Future<bool> hasChip({required NfcChipIdentifier chipIdentifier}) async => false;

  @override
  Future<bool> linkChipIfAbsent({required NfcChipIdentifier chipIdentifier}) async => linkChipIfAbsentResult;

  @override
  Future<void> renameChip({required String id, required String name}) async {
    if (renameError case final error?) {
      throw error;
    }
  }
}
