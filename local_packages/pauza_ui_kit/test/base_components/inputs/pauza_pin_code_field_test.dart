import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

void main() {
  testWidgets('renders configured amount of pin cells', (
    WidgetTester tester,
  ) async {
    final controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        theme: PauzaTheme.dark,
        home: Scaffold(
          body: PauzaPinCodeField(controller: controller, length: 6),
        ),
      ),
    );

    for (var i = 0; i < 6; i++) {
      expect(find.byKey(Key('pauza_pin_code_cell_$i')), findsOneWidget);
    }
  });

  testWidgets('accepts digits and enforces max length', (
    WidgetTester tester,
  ) async {
    final controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        theme: PauzaTheme.dark,
        home: Scaffold(
          body: PauzaPinCodeField(controller: controller, length: 6),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '12ab34567');
    await tester.pump();

    expect(controller.text, '1234');

    await tester.enterText(find.byType(TextField), '1234567');
    await tester.pump();

    expect(controller.text, '123456');
  });

  testWidgets('calls onFilled when code reaches full length', (
    WidgetTester tester,
  ) async {
    final controller = TextEditingController();
    var onFilledCallCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: PauzaTheme.dark,
        home: Scaffold(
          body: PauzaPinCodeField(
            controller: controller,
            length: 6,
            onFilled: () {
              onFilledCallCount += 1;
            },
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '123456');
    await tester.pump();

    expect(onFilledCallCount, 1);
  });

  testWidgets('disabled pin field does not accept text input', (
    WidgetTester tester,
  ) async {
    final controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        theme: PauzaTheme.dark,
        home: Scaffold(
          body: PauzaPinCodeField(
            controller: controller,
            enabled: false,
            length: 6,
          ),
        ),
      ),
    );

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.enabled, isFalse);

    await tester.enterText(find.byType(TextField), '123456');
    await tester.pump();

    expect(controller.text, isEmpty);
  });
}
