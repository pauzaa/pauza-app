import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pauza/src/features/nfc/model/nfc_card_dto.dart';
import 'package:pauza/src/features/nfc_chip_config/bloc/nfc_chip_conf_bloc.dart';
import 'package:pauza/src/features/nfc_chip_config/widget/nfc_chip_conf_content.dart';
import 'package:pauza/src/features/nfc_chip_config/widget/nfc_linked_chip_menu.dart';
import 'package:pauza/src/features/nfc_chip_config/widget/nfc_linked_chip_tile.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

import '../../../helpers/helpers.dart';

void main() {
  late MockNfcLinkedChipsRepository repository;

  setUpAll(registerTestFallbackValues);

  setUp(() {
    repository = MockNfcLinkedChipsRepository();
  });

  testWidgets('renders title, body, list item, and link button', (tester) async {
    final chip = makeNfcLinkedChip(id: 'chip-1', name: 'Home Desk Tag', createdAt: DateTime.utc(2023, 10, 24));
    when(() => repository.getLinkedChips()).thenAnswer((_) async => IList([chip]));

    final bloc = await _pumpScreen(tester, repository: repository);
    bloc.add(const NfcChipLoadCardsRequested());
    await tester.pump();
    await tester.pump();

    expect(find.text('Your NFC Tags'), findsOneWidget);
    expect(find.text('Link New Tag'), findsOneWidget);
    expect(find.descendant(of: find.byType(NfcLinkedChipTile), matching: find.text('Home Desk Tag')), findsOneWidget);
    expect(find.text('Linked on Oct 24, 2023'), findsOneWidget);
  });

  testWidgets('menu exposes rename and delete actions', (tester) async {
    final chip = makeNfcLinkedChip(id: 'chip-1', name: 'Kitchen Tag', createdAt: DateTime.utc(2023, 11, 2));
    when(() => repository.getLinkedChips()).thenAnswer((_) async => IList([chip]));

    final bloc = await _pumpScreen(tester, repository: repository);
    bloc.add(const NfcChipLoadCardsRequested());
    await tester.pump();
    await tester.pump();

    await tester.tap(find.byType(NfcLinkedChipMenu));
    await tester.pump();

    expect(find.text('Rename'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
  });

  testWidgets('rename action dispatches rename event', (tester) async {
    final chip = makeNfcLinkedChip(id: 'chip-1', name: 'Office Entry', createdAt: DateTime.utc(2023, 12, 15));
    when(() => repository.getLinkedChips()).thenAnswer((_) async => IList([chip]));
    when(
      () => repository.renameChip(
        id: any(named: 'id'),
        name: any(named: 'name'),
      ),
    ).thenAnswer((_) async {});

    final bloc = await _pumpScreen(
      tester,
      repository: repository,
      renameDialogOpener: (_, {required initialName}) async => 'Office Door',
    );
    bloc.add(const NfcChipLoadCardsRequested());
    await tester.pump();
    await tester.pump();

    final popupMenuButton = tester.widget<PopupMenuButton<NfcLinkedChipMenuAction>>(
      find.descendant(
        of: find.byType(NfcLinkedChipMenu),
        matching: find.byType(PopupMenuButton<NfcLinkedChipMenuAction>),
      ),
    );
    popupMenuButton.onSelected?.call(NfcLinkedChipMenuAction.rename);
    await tester.pump();
    await tester.pump();

    verify(() => repository.renameChip(id: 'chip-1', name: 'Office Door')).called(1);
  });

  testWidgets('delete action dispatches delete event', (tester) async {
    final chip = makeNfcLinkedChip(id: 'chip-1', name: 'Travel Pack', createdAt: DateTime.utc(2023, 1, 10));
    when(() => repository.getLinkedChips()).thenAnswer((_) async => IList([chip]));
    when(() => repository.deleteChip(id: any(named: 'id'))).thenAnswer((_) async {});

    final bloc = await _pumpScreen(tester, repository: repository);
    bloc.add(const NfcChipLoadCardsRequested());
    await tester.pump();
    await tester.pump();

    final popupMenuButton = tester.widget<PopupMenuButton<NfcLinkedChipMenuAction>>(
      find.descendant(
        of: find.byType(NfcLinkedChipMenu),
        matching: find.byType(PopupMenuButton<NfcLinkedChipMenuAction>),
      ),
    );
    popupMenuButton.onSelected?.call(NfcLinkedChipMenuAction.delete);
    await tester.pump();
    await tester.pump();

    verify(() => repository.deleteChip(id: 'chip-1')).called(1);
  });

  testWidgets('loading state disables link button and menu', (tester) async {
    final chip = makeNfcLinkedChip(id: 'chip-1', name: 'Kitchen Tag', createdAt: DateTime.utc(2023, 11, 2));
    final renameCompleter = Completer<void>();
    when(() => repository.getLinkedChips()).thenAnswer((_) async => IList([chip]));
    when(
      () => repository.renameChip(
        id: any(named: 'id'),
        name: any(named: 'name'),
      ),
    ).thenAnswer((_) => renameCompleter.future);

    final bloc = await _pumpScreen(
      tester,
      repository: repository,
      renameDialogOpener: (_, {required initialName}) async => 'Updated Kitchen Tag',
    );
    bloc.add(const NfcChipLoadCardsRequested());
    await tester.pump();
    await tester.pump();

    final popupMenuButton = tester.widget<PopupMenuButton<NfcLinkedChipMenuAction>>(
      find.descendant(
        of: find.byType(NfcLinkedChipMenu),
        matching: find.byType(PopupMenuButton<NfcLinkedChipMenuAction>),
      ),
    );
    popupMenuButton.onSelected?.call(NfcLinkedChipMenuAction.rename);
    await tester.pump();

    final filledButton = tester.widget<PauzaFilledButton>(find.byType(PauzaFilledButton));
    expect(filledButton.disabled, isTrue);

    final disabledMenuButton = tester.widget<PopupMenuButton<NfcLinkedChipMenuAction>>(
      find.descendant(
        of: find.byType(NfcLinkedChipMenu),
        matching: find.byType(PopupMenuButton<NfcLinkedChipMenuAction>),
      ),
    );
    expect(disabledMenuButton.enabled, isFalse);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);

    renameCompleter.complete();
    await tester.pump();
  });

  testWidgets('shows already linked toast on duplicate link error', (tester) async {
    when(
      () => repository.linkChipIfAbsent(chipIdentifier: any(named: 'chipIdentifier')),
    ).thenAnswer((_) async => false);

    final bloc = await _pumpScreen(tester, repository: repository, scanSheetOpener: (_) async => makeNfcCardDto());
    bloc.add(const NfcChipLoadCardsRequested());
    await tester.pump();
    await tester.pump();

    await tester.tap(find.widgetWithText(PauzaFilledButton, 'Link New Tag'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('This NFC tag is already linked.'), findsOneWidget);
  });
}

Future<NfcChipConfBloc> _pumpScreen(
  WidgetTester tester, {
  required MockNfcLinkedChipsRepository repository,
  Future<NfcCardDto?> Function(BuildContext context) scanSheetOpener = _noScan,
  Future<String?> Function(BuildContext context, {required String initialName}) renameDialogOpener = _noRename,
}) async {
  final bloc = NfcChipConfBloc(linkedChipsRepository: repository);
  addTearDown(bloc.close);

  await tester.pumpApp(
    BlocProvider<NfcChipConfBloc>.value(
      value: bloc,
      child: NfcChipConfContent(scanSheetOpener: scanSheetOpener, renameDialogOpener: renameDialogOpener),
    ),
    theme: PauzaTheme.dark,
  );

  return bloc;
}

Future<NfcCardDto?> _noScan(BuildContext context) async {
  return null;
}

Future<String?> _noRename(BuildContext context, {required String initialName}) async {
  return null;
}
