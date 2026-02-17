import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

void main() {
  testWidgets('renders greeting and title', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: PauzaTheme.dark,
        home: const Scaffold(
          body: PauzaDashboardAppBar(
            greeting: 'Good Evening',
            title: 'Pauza Dashboard',
            showSettingsButton: false,
          ),
        ),
      ),
    );

    expect(find.text('GOOD EVENING'), findsOneWidget);
    expect(find.text('Pauza Dashboard'), findsOneWidget);
    expect(find.byIcon(Icons.settings), findsNothing);
  });

  testWidgets('hides greeting when showGreeting is false', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: PauzaTheme.dark,
        home: const Scaffold(
          body: PauzaDashboardAppBar(
            greeting: 'Good Evening',
            title: 'Pauza Dashboard',
            showGreeting: false,
            showSettingsButton: false,
          ),
        ),
      ),
    );

    expect(find.text('GOOD EVENING'), findsNothing);
    expect(find.text('Pauza Dashboard'), findsOneWidget);
  });

  testWidgets('shows settings button and handles tap', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: PauzaTheme.dark,
        home: Scaffold(
          body: PauzaDashboardAppBar(
            greeting: 'Good Evening',
            title: 'Pauza Dashboard',
            onSettingsPressed: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    final settingsFinder = find.byIcon(Icons.settings);
    expect(settingsFinder, findsOneWidget);

    await tester.tap(settingsFinder);
    await tester.pump();

    expect(tapped, isTrue);
  });
}
