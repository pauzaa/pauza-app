import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

void main() {
  testWidgets('PauzaSwitch toggles in stateful host', (
    WidgetTester tester,
  ) async {
    var value = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: PauzaTheme.light,
        home: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Scaffold(
              body: PauzaSwitch(
                value: value,
                label: 'Enabled',
                onChanged: (bool next) {
                  setState(() {
                    value = next;
                  });
                },
              ),
            );
          },
        ),
      ),
    );

    expect(find.text('Enabled'), findsOneWidget);
    expect(value, isFalse);
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(value, isTrue);
  });
}
