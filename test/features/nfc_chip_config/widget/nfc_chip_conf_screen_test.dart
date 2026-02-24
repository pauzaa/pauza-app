import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/core/localization/gen/app_localizations.g.dart';
import 'package:pauza/src/features/nfc/model/nfc_card_dto.dart';
import 'package:pauza/src/features/nfc/model/nfc_chip_identifier.dart';
import 'package:pauza/src/features/nfc_chip_config/bloc/nfc_chip_conf_bloc.dart';
import 'package:pauza/src/features/nfc_chip_config/data/nfc_chip_config_error.dart';
import 'package:pauza/src/features/nfc_chip_config/data/nfc_linked_chips_repository.dart';
import 'package:pauza/src/features/nfc_chip_config/model/nfc_linked_chip.dart';
import 'package:pauza/src/features/nfc_chip_config/widget/nfc_chip_conf_content.dart';
import 'package:pauza/src/features/nfc_chip_config/widget/nfc_linked_chip_menu.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

void main() {
  testWidgets('renders title, body, list item, and link button', (tester) async {
    final bloc = _RecordingNfcChipConfBloc();
    addTearDown(bloc.close);

    await tester.pumpWidget(_TestApp(bloc: bloc));
    bloc.emitState(
      NfcChipConfIdle(
        linkedChips: [_chip(id: 'chip-1', name: 'Home Desk Tag', createdAt: DateTime.utc(2023, 10, 24))].lock,
      ),
    );
    await tester.pump();

    expect(find.text('Your NFC Tags'), findsOneWidget);
    expect(find.text('Link New Tag'), findsOneWidget);
    expect(find.text('Home Desk Tag'), findsOneWidget);
    expect(find.text('Linked on Oct 24, 2023'), findsOneWidget);
  });

  testWidgets('menu exposes rename and delete actions', (tester) async {
    final bloc = _RecordingNfcChipConfBloc();
    addTearDown(bloc.close);

    await tester.pumpWidget(_TestApp(bloc: bloc));
    bloc.emitState(
      NfcChipConfIdle(
        linkedChips: [_chip(id: 'chip-1', name: 'Kitchen Tag', createdAt: DateTime.utc(2023, 11, 2))].lock,
      ),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pump();

    expect(find.text('Rename'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
  });

  testWidgets('rename action dispatches rename event', (tester) async {
    final bloc = _RecordingNfcChipConfBloc();
    addTearDown(bloc.close);

    await tester.pumpWidget(
      _TestApp(bloc: bloc, renameDialogOpener: (_, {required initialName}) async => 'Office Door'),
    );
    bloc.emitState(
      NfcChipConfIdle(
        linkedChips: [_chip(id: 'chip-1', name: 'Office Entry', createdAt: DateTime.utc(2023, 12, 15))].lock,
      ),
    );
    await tester.pump();

    final popupMenuButton = tester.widget<PopupMenuButton<NfcLinkedChipMenuAction>>(
      find.byType(PopupMenuButton<NfcLinkedChipMenuAction>),
    );
    popupMenuButton.onSelected?.call(NfcLinkedChipMenuAction.rename);
    await tester.pump();

    final event = bloc.events.last;
    expect(event, isA<NfcChipRenameCardRequested>());
    final renameEvent = event as NfcChipRenameCardRequested;
    expect(renameEvent.cardId, 'chip-1');
    expect(renameEvent.newName, 'Office Door');
  });

  testWidgets('delete action dispatches delete event', (tester) async {
    final bloc = _RecordingNfcChipConfBloc();
    addTearDown(bloc.close);

    await tester.pumpWidget(_TestApp(bloc: bloc));
    bloc.emitState(
      NfcChipConfIdle(
        linkedChips: [_chip(id: 'chip-1', name: 'Travel Pack', createdAt: DateTime.utc(2023, 1, 10))].lock,
      ),
    );
    await tester.pump();

    final popupMenuButton = tester.widget<PopupMenuButton<NfcLinkedChipMenuAction>>(
      find.byType(PopupMenuButton<NfcLinkedChipMenuAction>),
    );
    popupMenuButton.onSelected?.call(NfcLinkedChipMenuAction.delete);
    await tester.pump();

    final event = bloc.events.last;
    expect(event, isA<NfcChipDeleteCardRequested>());
    final deleteEvent = event as NfcChipDeleteCardRequested;
    expect(deleteEvent.cardId, 'chip-1');
  });

  testWidgets('loading state disables link button and menu', (tester) async {
    final bloc = _RecordingNfcChipConfBloc();
    addTearDown(bloc.close);

    await tester.pumpWidget(_TestApp(bloc: bloc));
    bloc.emitState(
      NfcChipConfLoading(
        linkedChips: [_chip(id: 'chip-1', name: 'Kitchen Tag', createdAt: DateTime.utc(2023, 11, 2))].lock,
      ),
    );
    await tester.pump();

    final filledButton = tester.widget<PauzaFilledButton>(find.byType(PauzaFilledButton));
    expect(filledButton.disabled, isTrue);

    final popupMenuButton = tester.widget<PopupMenuButton<NfcLinkedChipMenuAction>>(
      find.byType(PopupMenuButton<NfcLinkedChipMenuAction>),
    );
    expect(popupMenuButton.enabled, isFalse);
  });

  testWidgets('shows already linked toast on duplicate link error', (tester) async {
    final bloc = _RecordingNfcChipConfBloc();
    addTearDown(bloc.close);

    await tester.pumpWidget(_TestApp(bloc: bloc));

    bloc.emitState(const NfcChipConfError(error: NfcChipConfigAlreadyLinkedError(), linkedChips: IList.empty()));
    await tester.pump();

    expect(find.text('This NFC tag is already linked.'), findsOneWidget);
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.bloc, this.renameDialogOpener});

  final _RecordingNfcChipConfBloc bloc;
  final Future<String?> Function(BuildContext context, {required String initialName})? renameDialogOpener;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: PauzaTheme.dark,
      home: BlocProvider<NfcChipConfBloc>.value(
        value: bloc,
        child: NfcChipConfContent(scanSheetOpener: _noScan, renameDialogOpener: renameDialogOpener ?? _noRename),
      ),
    );
  }

  Future<NfcCardDto?> _noScan(BuildContext context) async {
    return null;
  }

  Future<String?> _noRename(BuildContext context, {required String initialName}) async {
    return null;
  }
}

final class _RecordingNfcChipConfBloc extends NfcChipConfBloc {
  _RecordingNfcChipConfBloc() : super(linkedChipsRepository: _NoopNfcLinkedChipsRepository());

  final List<NfcChipConfEvent> events = <NfcChipConfEvent>[];

  @override
  void add(NfcChipConfEvent event) {
    events.add(event);
  }

  void emitState(NfcChipConfState state) {
    emit(state);
  }
}

final class _NoopNfcLinkedChipsRepository implements NfcLinkedChipsRepository {
  @override
  Future<void> deleteChip({required String id}) async {}

  @override
  Future<IList<NfcLinkedChip>> getLinkedChips() async {
    return const IList.empty();
  }

  @override
  Future<bool> hasChip({required NfcChipIdentifier chipIdentifier}) async {
    return false;
  }

  @override
  Future<bool> hasLinkedChips() async {
    return false;
  }

  @override
  Future<bool> linkChipIfAbsent({required NfcChipIdentifier chipIdentifier}) async {
    return false;
  }

  @override
  Future<void> renameChip({required String id, required String name}) async {}
}

NfcLinkedChip _chip({required String id, required String name, required DateTime createdAt}) {
  return NfcLinkedChip(id: id, chipIdentifier: id, name: name, createdAt: createdAt, updatedAt: createdAt);
}
