import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/core/localization/gen/app_localizations.g.dart';
import 'package:pauza/src/features/modes/add_edit/bloc/mode_editor_bloc.dart';
import 'package:pauza/src/features/modes/add_edit/widgets/mode_editor_screen.dart';
import 'package:pauza/src/features/modes/common/data/modes_repository.dart';
import 'package:pauza/src/features/modes/common/model/mode.dart';
import 'package:pauza/src/features/modes/common/model/mode_upsert.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

void main() {
  testWidgets('delete button appears only in edit mode', (tester) async {
    final createBloc = ModeEditorBloc(modesRepository: _TestModesRepository());
    addTearDown(createBloc.close);
    await tester.pumpWidget(
      _TestApp(
        bloc: createBloc,
        child: const ModeEditorMainScreen(modeId: null),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Delete Focus Mode'), findsNothing);

    final editBloc = ModeEditorBloc(modesRepository: _TestModesRepository());
    addTearDown(editBloc.close);
    await tester.pumpWidget(
      _TestApp(
        bloc: editBloc,
        child: const ModeEditorMainScreen(modeId: 'mode-1'),
      ),
    );
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.text('Delete Focus Mode').evaluate().isNotEmpty) {
        break;
      }
    }

    await tester.drag(find.byType(ListView), const Offset(0, -1000));
    await tester.pump();

    expect(find.text('Delete Focus Mode'), findsOneWidget);
  });

  testWidgets('save with empty fields shows notifier validation errors', (
    tester,
  ) async {
    final bloc = ModeEditorBloc(modesRepository: _TestModesRepository());
    addTearDown(bloc.close);
    await tester.pumpWidget(
      _TestApp(bloc: bloc, child: const ModeEditorMainScreen(modeId: null)),
    );
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('Save Mode'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('This field is required'), findsAtLeastNWidgets(1));
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.bloc, required this.child});

  final ModeEditorBloc bloc;
  final Widget child;

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
      home: BlocProvider<ModeEditorBloc>.value(value: bloc, child: child),
    );
  }
}

class _TestModesRepository implements ModesRepository {
  @override
  Future<void> createMode(ModeUpsertDTO request) async {}

  @override
  Future<void> deleteMode(String modeId) async {}

  @override
  Future<Mode> getMode(String modeId) async {
    return Mode(
      id: modeId,
      title: 'Deep Work',
      textOnScreen: 'Stay focused',
      description: 'desc',
      allowedPausesCount: 2,
      schedule: null,
      blockedAppIds: const ISet.empty(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<List<Mode>> getModes() async => <Mode>[];

  @override
  Future<void> updateMode({
    required String modeId,
    required ModeUpsertDTO request,
  }) async {}
}
