import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

void main() {
  testWidgets('PauzaFilledButton triggers onPressed', (WidgetTester tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: PauzaTheme.light,
        home: Scaffold(
          body: PauzaFilledButton(
            title: const Text('Tap'),
            onPressed: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Tap'));
    expect(tapped, isTrue);
  });

  testWidgets('PauzaFilledButton disabled/loading does not trigger', (WidgetTester tester) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: PauzaTheme.light,
        home: Scaffold(
          body: Column(
            children: <Widget>[
              PauzaFilledButton(
                title: const Text('Disabled'),
                onPressed: () {
                  taps++;
                },
                disabled: true,
              ),
              PauzaFilledButton(
                disabled: true,
                title: const Text('Loading'),
                onPressed: () {
                  taps++;
                },
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('Disabled'));
    await tester.tap(find.text('Loading'));
    expect(taps, 0);
  });
}
