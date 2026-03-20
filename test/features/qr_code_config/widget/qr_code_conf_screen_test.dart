import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pauza/src/features/qr_code_config/bloc/qr_code_conf_bloc.dart';
import 'package:pauza/src/features/qr_code_config/model/qr_linked_code.dart';
import 'package:pauza/src/features/qr_code_config/widget/qr_code_conf_content.dart';
import 'package:pauza/src/features/qr_code_config/widget/qr_linked_code_menu.dart';
import 'package:pauza/src/features/qr_code_config/widget/qr_linked_code_tile.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

import '../../../helpers/helpers.dart';

void main() {
  late MockQrLinkedCodesRepository repository;

  setUpAll(registerTestFallbackValues);

  setUp(() {
    repository = MockQrLinkedCodesRepository();
  });

  testWidgets('renders title, body, list item, and generate button', (tester) async {
    final code = makeQrLinkedCode(id: 'code-1', name: 'Home QR', createdAt: DateTime.utc(2023, 10, 24));
    when(() => repository.getLinkedCodes()).thenAnswer((_) async => IList<QrLinkedCode>([code]));

    final bloc = await _pumpScreen(tester, repository: repository);
    bloc.add(const QrCodeLoadCodesRequested());
    await tester.pump();
    await tester.pump();

    expect(find.text('Your QR Codes'), findsOneWidget);
    expect(find.text('Generate New QR'), findsOneWidget);
    expect(find.descendant(of: find.byType(QrLinkedCodeTile), matching: find.text('Home QR')), findsOneWidget);
    expect(find.text('Linked on Oct 24, 2023'), findsOneWidget);
  });

  testWidgets('shows empty state when no linked codes', (tester) async {
    when(() => repository.getLinkedCodes()).thenAnswer((_) async => const IList<QrLinkedCode>.empty());

    final bloc = await _pumpScreen(tester, repository: repository);
    bloc.add(const QrCodeLoadCodesRequested());
    await tester.pump();
    await tester.pump();

    expect(find.text('No linked QR codes yet'), findsOneWidget);
    expect(find.text('Generate your first QR code to manage focus session unlocking.'), findsOneWidget);
  });

  testWidgets('menu exposes rename and delete actions', (tester) async {
    final code = makeQrLinkedCode(id: 'code-1', name: 'Kitchen QR', createdAt: DateTime.utc(2023, 11, 2));
    when(() => repository.getLinkedCodes()).thenAnswer((_) async => IList<QrLinkedCode>([code]));

    final bloc = await _pumpScreen(tester, repository: repository);
    bloc.add(const QrCodeLoadCodesRequested());
    await tester.pump();
    await tester.pump();

    await tester.tap(find.byType(QrLinkedCodeMenu));
    await tester.pump();

    expect(find.text('Rename'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
  });

  testWidgets('rename action dispatches rename event', (tester) async {
    final code = makeQrLinkedCode(id: 'code-1', name: 'Office Entry', createdAt: DateTime.utc(2023, 12, 15));
    when(() => repository.getLinkedCodes()).thenAnswer((_) async => IList<QrLinkedCode>([code]));
    when(
      () => repository.renameCode(
        id: any(named: 'id'),
        name: any(named: 'name'),
      ),
    ).thenAnswer((_) async {});

    final bloc = await _pumpScreen(
      tester,
      repository: repository,
      renameDialogOpener: (_, {required initialName}) async => 'Office QR',
    );
    bloc.add(const QrCodeLoadCodesRequested());
    await tester.pump();
    await tester.pump();

    final popupMenuButton = tester.widget<PopupMenuButton<QrLinkedCodeMenuAction>>(
      find.descendant(
        of: find.byType(QrLinkedCodeMenu),
        matching: find.byType(PopupMenuButton<QrLinkedCodeMenuAction>),
      ),
    );
    popupMenuButton.onSelected?.call(QrLinkedCodeMenuAction.rename);
    await tester.pump();
    await tester.pump();

    verify(() => repository.renameCode(id: 'code-1', name: 'Office QR')).called(1);
  });

  testWidgets('delete action dispatches delete event', (tester) async {
    final code = makeQrLinkedCode(id: 'code-1', name: 'Travel QR', createdAt: DateTime.utc(2023, 1, 10));
    when(() => repository.getLinkedCodes()).thenAnswer((_) async => IList<QrLinkedCode>([code]));
    when(() => repository.deleteCode(id: any(named: 'id'))).thenAnswer((_) async {});

    final bloc = await _pumpScreen(tester, repository: repository);
    bloc.add(const QrCodeLoadCodesRequested());
    await tester.pump();
    await tester.pump();

    final popupMenuButton = tester.widget<PopupMenuButton<QrLinkedCodeMenuAction>>(
      find.descendant(
        of: find.byType(QrLinkedCodeMenu),
        matching: find.byType(PopupMenuButton<QrLinkedCodeMenuAction>),
      ),
    );
    popupMenuButton.onSelected?.call(QrLinkedCodeMenuAction.delete);
    await tester.pump();
    await tester.pump();

    verify(() => repository.deleteCode(id: 'code-1')).called(1);
  });

  testWidgets('generate button dispatches generate event', (tester) async {
    when(() => repository.getLinkedCodes()).thenAnswer((_) async => const IList<QrLinkedCode>.empty());
    when(() => repository.generateAndLinkCode()).thenAnswer((_) async => makeQrLinkedCode(id: 'generated-code'));

    final bloc = await _pumpScreen(tester, repository: repository);
    bloc.add(const QrCodeLoadCodesRequested());
    await tester.pump();
    await tester.pump();

    await tester.tap(find.widgetWithText(PauzaFilledButton, 'Generate New QR'));
    await tester.pump();

    verify(() => repository.generateAndLinkCode()).called(1);
  });

  testWidgets('loading state disables actions and shows linear progress', (tester) async {
    final code = makeQrLinkedCode(id: 'code-1', name: 'Kitchen QR', createdAt: DateTime.utc(2023, 11, 2));
    final renameCompleter = Completer<void>();
    when(() => repository.getLinkedCodes()).thenAnswer((_) async => IList<QrLinkedCode>([code]));
    when(
      () => repository.renameCode(
        id: any(named: 'id'),
        name: any(named: 'name'),
      ),
    ).thenAnswer((_) => renameCompleter.future);

    final bloc = await _pumpScreen(
      tester,
      repository: repository,
      renameDialogOpener: (_, {required initialName}) async => 'Updated Kitchen QR',
    );
    bloc.add(const QrCodeLoadCodesRequested());
    await tester.pump();
    await tester.pump();

    final popupMenuButton = tester.widget<PopupMenuButton<QrLinkedCodeMenuAction>>(
      find.descendant(
        of: find.byType(QrLinkedCodeMenu),
        matching: find.byType(PopupMenuButton<QrLinkedCodeMenuAction>),
      ),
    );
    popupMenuButton.onSelected?.call(QrLinkedCodeMenuAction.rename);
    await tester.pump();

    final filledButton = tester.widget<PauzaFilledButton>(find.byType(PauzaFilledButton));
    expect(filledButton.disabled, isTrue);

    final disabledMenuButton = tester.widget<PopupMenuButton<QrLinkedCodeMenuAction>>(
      find.descendant(
        of: find.byType(QrLinkedCodeMenu),
        matching: find.byType(PopupMenuButton<QrLinkedCodeMenuAction>),
      ),
    );
    expect(disabledMenuButton.enabled, isFalse);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);

    renameCompleter.complete();
    await tester.pump();
  });

  testWidgets('tapping tile opens preview dialog opener with selected code', (tester) async {
    final code = makeQrLinkedCode(id: 'code-1', name: 'Desk QR', createdAt: DateTime.utc(2023, 11, 2));
    QrLinkedCode? openedCode;
    when(() => repository.getLinkedCodes()).thenAnswer((_) async => IList<QrLinkedCode>([code]));

    final bloc = await _pumpScreen(
      tester,
      repository: repository,
      previewDialogOpener: (_, {required code}) async {
        openedCode = code;
      },
    );
    bloc.add(const QrCodeLoadCodesRequested());
    await tester.pump();
    await tester.pump();

    await tester.tap(find.byType(QrLinkedCodeTile));
    await tester.pump();

    expect(openedCode?.id, 'code-1');
  });
}

Future<QrCodeConfBloc> _pumpScreen(
  WidgetTester tester, {
  required MockQrLinkedCodesRepository repository,
  Future<String?> Function(BuildContext context, {required String initialName}) renameDialogOpener = _noRename,
  Future<void> Function(BuildContext context, {required QrLinkedCode code}) previewDialogOpener = _noPreview,
}) async {
  final bloc = QrCodeConfBloc(linkedCodesRepository: repository);
  addTearDown(bloc.close);

  await tester.pumpApp(
    BlocProvider<QrCodeConfBloc>.value(
      value: bloc,
      child: QrCodeConfContent(renameDialogOpener: renameDialogOpener, previewDialogOpener: previewDialogOpener),
    ),
    theme: PauzaTheme.dark,
  );

  return bloc;
}

Future<String?> _noRename(BuildContext context, {required String initialName}) async {
  return null;
}

Future<void> _noPreview(BuildContext context, {required QrLinkedCode code}) async {}
