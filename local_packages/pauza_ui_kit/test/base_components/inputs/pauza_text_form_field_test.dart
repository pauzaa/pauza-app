import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

void main() {
  testWidgets('PauzaTextFormField renders label above field', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: PauzaTheme.light,
        home: Scaffold(
          body: PauzaTextFormField(
            onChanged: (_) {},
            decoration: const PauzaInputDecoration(labelText: 'Email'),
          ),
        ),
      ),
    );

    expect(find.text('Email'), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget);
  });

  testWidgets('PauzaInputDecoration clear icon clears text', (
    WidgetTester tester,
  ) async {
    final controller = TextEditingController(text: 'hello');
    await tester.pumpWidget(
      MaterialApp(
        theme: PauzaTheme.light,
        home: Scaffold(
          body: PauzaTextFormField(
            controller: controller,
            onChanged: (_) {},
            decoration: const PauzaInputDecoration(
              automaticallyImplyClear: true,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(TextFormField));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.cancel_outlined), findsOneWidget);
    await tester.tap(find.byIcon(Icons.cancel_outlined));
    await tester.pumpAndSettle();
    expect(controller.text, isEmpty);
  });
}
