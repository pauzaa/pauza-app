import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/core/localization/gen/app_localizations.g.dart';
import 'package:pauza/src/features/qr_code_config/widget/qr_code_rename_dialog.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

void main() {
  testWidgets('save is disabled for blank input and returns trimmed value', (tester) async {
    final result = ValueNotifier<String?>(null);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        theme: PauzaTheme.dark,
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () async {
                  result.value = await QrCodeRenameDialog.show(context, initialName: 'Home QR');
                },
                child: const Text('open'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pump();

    expect(find.text('Rename QR Code'), findsOneWidget);

    await tester.enterText(find.byType(EditableText), '   ');
    await tester.pump();

    final disabledSaveButton = tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Save'));
    expect(disabledSaveButton.onPressed, isNull);

    await tester.enterText(find.byType(EditableText), '  Office QR  ');
    await tester.pump();

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pump();

    expect(result.value, 'Office QR');
  });
}
