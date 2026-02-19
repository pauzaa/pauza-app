import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

void main() {
  Widget buildTestApp(Widget child) {
    return MaterialApp(
      theme: PauzaTheme.light,
      home: Scaffold(body: child),
    );
  }

  TextStyle buttonTextStyle(WidgetTester tester) {
    final button = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
    return button.style!.textStyle!.resolve(const <WidgetState>{})!;
  }

  testWidgets('PauzaFilledButton triggers onPressed', (
    WidgetTester tester,
  ) async {
    var tapped = false;
    await tester.pumpWidget(
      buildTestApp(
        PauzaFilledButton(
          title: const Text('Tap'),
          onPressed: () {
            tapped = true;
          },
        ),
      ),
    );

    await tester.tap(find.text('Tap'));
    expect(tapped, isTrue);
  });

  testWidgets('PauzaButtonSize text styles map to expected text theme tokens', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        Builder(
          builder: (context) {
            final textTheme = context.textTheme;

            expect(
              PauzaButtonSize.xxSmall.textStyle(context),
              textTheme.labelSmall,
            );
            expect(
              PauzaButtonSize.xSmall.textStyle(context),
              textTheme.labelLarge,
            );
            expect(
              PauzaButtonSize.small.textStyle(context),
              textTheme.labelLarge,
            );
            expect(
              PauzaButtonSize.medium.textStyle(context),
              textTheme.titleLarge,
            );
            expect(
              PauzaButtonSize.large.textStyle(context),
              textTheme.headlineSmall,
            );

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  });

  testWidgets('PauzaFilledButton uses mapped text style defaults by size', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        PauzaFilledButton(title: const Text('Medium'), onPressed: () {}),
      ),
    );

    final mediumStyle = buttonTextStyle(tester);
    expect(mediumStyle.fontSize, 22);
    expect(mediumStyle.fontWeight, FontWeight.w700);

    await tester.pumpWidget(
      buildTestApp(
        PauzaFilledButton(
          title: const Text('Large'),
          onPressed: () {},
          size: PauzaButtonSize.large,
        ),
      ),
    );

    final largeStyle = buttonTextStyle(tester);
    expect(largeStyle.fontSize, 24);
    expect(largeStyle.fontWeight, FontWeight.w700);
  });

  testWidgets('PauzaFilledButton honors explicit textStyle override', (
    WidgetTester tester,
  ) async {
    const overrideStyle = TextStyle(fontSize: 17, fontWeight: FontWeight.w400);

    await tester.pumpWidget(
      buildTestApp(
        PauzaFilledButton(
          title: const Text('Override'),
          onPressed: () {},
          textStyle: overrideStyle,
        ),
      ),
    );

    final style = buttonTextStyle(tester);
    expect(style.fontSize, overrideStyle.fontSize);
    expect(style.fontWeight, overrideStyle.fontWeight);
  });

  testWidgets('PauzaFilledButton disabled/loading does not trigger', (
    WidgetTester tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      buildTestApp(
        Column(
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
    );

    await tester.tap(find.text('Disabled'));
    await tester.tap(find.text('Loading'));
    expect(taps, 0);
  });
}
