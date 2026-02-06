import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

void main() {
  testWidgets('PauzaCheckbox toggles value', (WidgetTester tester) async {
    bool? value = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: PauzaTheme.light,
        home: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Scaffold(
              body: PauzaCheckbox(
                value: value,
                onChanged: (bool? next) {
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

    expect(find.byIcon(Icons.check), findsNothing);
    await tester.tap(find.byType(PauzaCheckbox));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check), findsOneWidget);
  });
}
