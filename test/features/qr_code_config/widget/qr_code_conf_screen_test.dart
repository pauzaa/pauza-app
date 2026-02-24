import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/core/localization/gen/app_localizations.g.dart';
import 'package:pauza/src/features/qr_code_config/bloc/qr_code_conf_bloc.dart';
import 'package:pauza/src/features/qr_code_config/data/qr_linked_codes_repository.dart';
import 'package:pauza/src/features/qr_code_config/model/qr_linked_code.dart';
import 'package:pauza/src/features/qr_code_config/model/qr_unlock_token.dart';
import 'package:pauza/src/features/qr_code_config/widget/qr_code_conf_content.dart';
import 'package:pauza/src/features/qr_code_config/widget/qr_linked_code_menu.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

void main() {
  testWidgets('renders title, body, list item, and generate button', (tester) async {
    final bloc = _RecordingQrCodeConfBloc();
    addTearDown(bloc.close);

    await tester.pumpWidget(_TestApp(bloc: bloc));
    bloc.emitState(
      QrCodeConfIdle(
        linkedCodes: [_code(id: 'code-1', name: 'Home QR', createdAt: DateTime.utc(2023, 10, 24))].lock,
      ),
    );
    await tester.pump();

    expect(find.text('Your QR Codes'), findsOneWidget);
    expect(find.text('Generate New QR'), findsOneWidget);
    expect(find.text('Home QR'), findsOneWidget);
    expect(find.text('Linked on Oct 24, 2023'), findsOneWidget);
  });

  testWidgets('shows empty state when no linked codes', (tester) async {
    final bloc = _RecordingQrCodeConfBloc();
    addTearDown(bloc.close);

    await tester.pumpWidget(_TestApp(bloc: bloc));
    bloc.emitState(const QrCodeConfIdle(linkedCodes: IList.empty()));
    await tester.pump();

    expect(find.text('No linked QR codes yet'), findsOneWidget);
    expect(find.text('Generate your first QR code to manage focus session unlocking.'), findsOneWidget);
  });

  testWidgets('menu exposes rename and delete actions', (tester) async {
    final bloc = _RecordingQrCodeConfBloc();
    addTearDown(bloc.close);

    await tester.pumpWidget(_TestApp(bloc: bloc));
    bloc.emitState(
      QrCodeConfIdle(
        linkedCodes: [_code(id: 'code-1', name: 'Kitchen QR', createdAt: DateTime.utc(2023, 11, 2))].lock,
      ),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pump();

    expect(find.text('Rename'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
  });

  testWidgets('rename action dispatches rename event', (tester) async {
    final bloc = _RecordingQrCodeConfBloc();
    addTearDown(bloc.close);

    await tester.pumpWidget(_TestApp(bloc: bloc, renameDialogOpener: (_, {required initialName}) async => 'Office QR'));
    bloc.emitState(
      QrCodeConfIdle(
        linkedCodes: [_code(id: 'code-1', name: 'Office Entry', createdAt: DateTime.utc(2023, 12, 15))].lock,
      ),
    );
    await tester.pump();

    final popupMenuButton = tester.widget<PopupMenuButton<QrLinkedCodeMenuAction>>(
      find.byType(PopupMenuButton<QrLinkedCodeMenuAction>),
    );
    popupMenuButton.onSelected?.call(QrLinkedCodeMenuAction.rename);
    await tester.pump();

    final event = bloc.events.last;
    expect(event, isA<QrCodeRenameCodeRequested>());
    final renameEvent = event as QrCodeRenameCodeRequested;
    expect(renameEvent.codeId, 'code-1');
    expect(renameEvent.newName, 'Office QR');
  });

  testWidgets('delete action dispatches delete event', (tester) async {
    final bloc = _RecordingQrCodeConfBloc();
    addTearDown(bloc.close);

    await tester.pumpWidget(_TestApp(bloc: bloc));
    bloc.emitState(
      QrCodeConfIdle(
        linkedCodes: [_code(id: 'code-1', name: 'Travel QR', createdAt: DateTime.utc(2023, 1, 10))].lock,
      ),
    );
    await tester.pump();

    final popupMenuButton = tester.widget<PopupMenuButton<QrLinkedCodeMenuAction>>(
      find.byType(PopupMenuButton<QrLinkedCodeMenuAction>),
    );
    popupMenuButton.onSelected?.call(QrLinkedCodeMenuAction.delete);
    await tester.pump();

    final event = bloc.events.last;
    expect(event, isA<QrCodeDeleteCodeRequested>());
    final deleteEvent = event as QrCodeDeleteCodeRequested;
    expect(deleteEvent.codeId, 'code-1');
  });

  testWidgets('generate button dispatches generate event', (tester) async {
    final bloc = _RecordingQrCodeConfBloc();
    addTearDown(bloc.close);

    await tester.pumpWidget(_TestApp(bloc: bloc));
    bloc.emitState(const QrCodeConfIdle(linkedCodes: IList.empty()));
    await tester.pump();

    await tester.tap(find.widgetWithText(PauzaFilledButton, 'Generate New QR'));
    await tester.pump();

    expect(bloc.events.last, isA<QrCodeGenerateCodeRequested>());
  });

  testWidgets('loading state disables actions and shows linear progress', (tester) async {
    final bloc = _RecordingQrCodeConfBloc();
    addTearDown(bloc.close);

    await tester.pumpWidget(_TestApp(bloc: bloc));
    bloc.emitState(
      QrCodeConfLoading(
        linkedCodes: [_code(id: 'code-1', name: 'Kitchen QR', createdAt: DateTime.utc(2023, 11, 2))].lock,
      ),
    );
    await tester.pump();

    final filledButton = tester.widget<PauzaFilledButton>(find.byType(PauzaFilledButton));
    expect(filledButton.disabled, isTrue);

    final popupMenuButton = tester.widget<PopupMenuButton<QrLinkedCodeMenuAction>>(
      find.byType(PopupMenuButton<QrLinkedCodeMenuAction>),
    );
    expect(popupMenuButton.enabled, isFalse);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('tapping tile opens preview dialog opener with selected code', (tester) async {
    final bloc = _RecordingQrCodeConfBloc();
    addTearDown(bloc.close);
    QrLinkedCode? openedCode;

    await tester.pumpWidget(
      _TestApp(
        bloc: bloc,
        previewDialogOpener: (_, {required code}) async {
          openedCode = code;
        },
      ),
    );
    bloc.emitState(
      QrCodeConfIdle(
        linkedCodes: [_code(id: 'code-1', name: 'Desk QR', createdAt: DateTime.utc(2023, 11, 2))].lock,
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Desk QR'));
    await tester.pump();

    expect(openedCode?.id, 'code-1');
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.bloc, this.renameDialogOpener, this.previewDialogOpener});

  final _RecordingQrCodeConfBloc bloc;
  final Future<String?> Function(BuildContext context, {required String initialName})? renameDialogOpener;
  final Future<void> Function(BuildContext context, {required QrLinkedCode code})? previewDialogOpener;

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
      home: BlocProvider<QrCodeConfBloc>.value(
        value: bloc,
        child: QrCodeConfContent(
          renameDialogOpener: renameDialogOpener ?? _noRename,
          previewDialogOpener: previewDialogOpener ?? _noPreview,
        ),
      ),
    );
  }

  Future<String?> _noRename(BuildContext context, {required String initialName}) async {
    return null;
  }

  Future<void> _noPreview(BuildContext context, {required QrLinkedCode code}) async {}
}

final class _RecordingQrCodeConfBloc extends QrCodeConfBloc {
  _RecordingQrCodeConfBloc() : super(linkedCodesRepository: _NoopQrLinkedCodesRepository());

  final List<QrCodeConfEvent> events = <QrCodeConfEvent>[];

  @override
  void add(QrCodeConfEvent event) {
    events.add(event);
  }

  void emitState(QrCodeConfState state) {
    emit(state);
  }
}

final class _NoopQrLinkedCodesRepository implements QrLinkedCodesRepository {
  @override
  Future<void> deleteCode({required String id}) async {}

  @override
  Future<QrLinkedCode> generateAndLinkCode() async {
    return _code(id: 'generated-id', name: 'Generated', createdAt: DateTime.utc(2023));
  }

  @override
  Future<IList<QrLinkedCode>> getLinkedCodes() async {
    return const IList.empty();
  }

  @override
  Future<bool> hasScanValue({required String scanValue}) async {
    return false;
  }

  @override
  Future<bool> hasLinkedCodes() async {
    return false;
  }

  @override
  Future<void> renameCode({required String id, required String name}) async {}
}

QrLinkedCode _code({required String id, required String name, required DateTime createdAt}) {
  return QrLinkedCode(
    id: id,
    scanValue: QrUnlockToken.parse('pauza:qr:v1:3f2504e0-4f89-41d3-9a0c-0305e82c3301'),
    name: name,
    createdAt: createdAt,
    updatedAt: createdAt,
  );
}
