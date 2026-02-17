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
            trailing: IconButton(onPressed: null, icon: Icon(Icons.settings)),
          ),
        ),
      ),
    );

    expect(find.text('GOOD EVENING'), findsOneWidget);
    expect(find.text('Pauza Dashboard'), findsOneWidget);
    expect(find.byIcon(Icons.settings), findsNothing);
  });
}
