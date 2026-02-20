import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

void main() {
  final languages = <Locale, String>{const Locale('en'): 'English', const Locale('ru'): 'Русский'};

  testWidgets('dialog shows supported languages and selected locale', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: PauzaTheme.light,
        home: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () {
                PauzaLanguagePickerDialog.show(
                  context,
                  currentLocale: const Locale('en'),
                  supportedLanguages: languages,
                );
              },
              child: const Text('open'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pump();

    expect(find.text('Language'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Русский'), findsOneWidget);
    expect(find.byIcon(Icons.radio_button_checked_rounded), findsOneWidget);
  });

  testWidgets('dialog returns selected locale', (tester) async {
    await tester.pumpWidget(MaterialApp(theme: PauzaTheme.light, home: const SizedBox.shrink()));

    final context = tester.element(find.byType(SizedBox));
    final resultFuture = PauzaLanguagePickerDialog.show(
      context,
      currentLocale: const Locale('en'),
      supportedLanguages: languages,
    );
    await tester.pump();

    await tester.tap(find.text('Русский'));
    await tester.pump();

    final result = await resultFuture;
    expect(result, const Locale('ru'));
  });

  testWidgets('dialog returns null when cancelled', (tester) async {
    await tester.pumpWidget(MaterialApp(theme: PauzaTheme.light, home: const SizedBox.shrink()));

    final context = tester.element(find.byType(SizedBox));
    final resultFuture = PauzaLanguagePickerDialog.show(
      context,
      currentLocale: const Locale('en'),
      supportedLanguages: languages,
    );
    await tester.pump();

    await tester.tap(find.text('Cancel'));
    await tester.pump();

    final result = await resultFuture;
    expect(result, isNull);
  });
}
