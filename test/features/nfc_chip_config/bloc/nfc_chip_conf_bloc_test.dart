import 'package:bloc_test/bloc_test.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pauza/src/features/nfc/model/nfc_card_dto.dart';
import 'package:pauza/src/features/nfc/model/nfc_chip_identifier.dart';
import 'package:pauza/src/features/nfc/model/nfc_ndef_record_dto.dart';
import 'package:pauza/src/features/nfc/model/nfc_tag_tech.dart';
import 'package:pauza/src/features/nfc_chip_config/bloc/nfc_chip_conf_bloc.dart';
import 'package:pauza/src/features/nfc_chip_config/data/nfc_chip_config_error.dart';

import '../../../helpers/helpers.dart';

/// Creates an [NfcCardDto] with a null [uidHex] for testing missing-identifier
/// scenarios. The shared [makeNfcCardDto] fixture always fills a non-null
/// default, so this local helper is needed.
NfcCardDto _cardWithoutUid() {
  return NfcCardDto(
    id: 'card',
    detectedAt: DateTime.utc(2024),
    uidHex: null,
    techTypes: const IListConst<NfcTagTech>(<NfcTagTech>[NfcTagTech.nfcA]),
    isNdefFormatted: false,
    ndefRecords: const IListConst<NfcNdefRecordDto>(<NfcNdefRecordDto>[]),
    rawSnapshot: const IMapConst<String, Object?>(<String, Object?>{}),
  );
}

void main() {
  late MockNfcLinkedChipsRepository repository;

  setUpAll(registerTestFallbackValues);

  setUp(() {
    repository = MockNfcLinkedChipsRepository();
  });

  group('NfcChipConfBloc', () {
    blocTest<NfcChipConfBloc, NfcChipConfState>(
      'emits already linked error when repository reports duplicate chip',
      setUp: () {
        when(
          () => repository.linkChipIfAbsent(chipIdentifier: any(named: 'chipIdentifier')),
        ).thenAnswer((_) async => false);
      },
      build: () => NfcChipConfBloc(linkedChipsRepository: repository),
      act: (bloc) => bloc.add(NfcChipLinkCardRequested(card: makeNfcCardDto(uidHex: NfcChipIdentifier.parse('a1b2')))),
      expect: () => <NfcChipConfState>[
        const NfcChipConfLoading(linkedChips: IList.empty()),
        const NfcChipConfError(error: NfcChipConfigAlreadyLinkedError(), linkedChips: IList.empty()),
      ],
    );

    blocTest<NfcChipConfBloc, NfcChipConfState>(
      'emits missing identifier error when scanned card uid is null',
      build: () => NfcChipConfBloc(linkedChipsRepository: repository),
      act: (bloc) => bloc.add(NfcChipLinkCardRequested(card: _cardWithoutUid())),
      expect: () => <NfcChipConfState>[
        const NfcChipConfLoading(linkedChips: IList.empty()),
        const NfcChipConfError(error: NfcChipConfigMissingIdentifierError(), linkedChips: IList.empty()),
      ],
    );

    blocTest<NfcChipConfBloc, NfcChipConfState>(
      'retains linked chips across loading and error states',
      setUp: () {
        when(
          () => repository.getLinkedChips(),
        ).thenAnswer((_) async => IList([makeNfcLinkedChip(id: 'chip-1', name: 'Desk Tag')]));
        when(
          () => repository.renameChip(
            id: any(named: 'id'),
            name: any(named: 'name'),
          ),
        ).thenThrow(StateError('rename failed'));
      },
      build: () => NfcChipConfBloc(linkedChipsRepository: repository),
      act: (bloc) async {
        bloc.add(const NfcChipLoadCardsRequested());
        await bloc.stream.firstWhere((state) => state is NfcChipConfIdle);
        bloc.add(const NfcChipRenameCardRequested(cardId: 'chip-1', newName: 'Desk'));
      },
      expect: () {
        final initialChip = makeNfcLinkedChip(id: 'chip-1', name: 'Desk Tag');
        return <Matcher>[
          equals(const NfcChipConfLoading(linkedChips: IList.empty())),
          equals(NfcChipConfIdle(linkedChips: IList([initialChip]))),
          equals(NfcChipConfLoading(linkedChips: IList([initialChip]))),
          isA<NfcChipConfError>()
              .having((s) => s.error, 'error', isA<StateError>())
              .having((s) => s.linkedChips, 'linkedChips', IList([initialChip])),
        ];
      },
    );
  });
}
