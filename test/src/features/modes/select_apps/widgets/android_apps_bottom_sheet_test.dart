import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/features/modes/select_apps/widgets/android_apps_bottom_sheet.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

void main() {
  group('AndroidAppsBottomSheet widgets', () {
    test('sheet can be constructed with initial IDs', () {
      expect(
        const AndroidAppsBottomSheet(initialSelectedAppIds: ISet<AppIdentifier>.empty()),
        isNotNull,
      );
    });

    testWidgets('selection primitives render and react', (tester) async {
      var selected = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: PauzaTheme.dark,
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Column(
                  children: [
                    PauzaFilterChip(
                      label: 'All Apps',
                      isSelected: selected,
                      onPressed: () {
                        setState(() {
                          selected = !selected;
                        });
                      },
                    ),
                    PauzaSelectionIndicator(isSelected: selected),
                  ],
                ),
              );
            },
          ),
        ),
      );

      expect(find.text('All Apps'), findsOneWidget);
      expect(find.byType(PauzaSelectionIndicator), findsOneWidget);

      await tester.tap(find.text('All Apps'));
      await tester.pump();

      expect(selected, isTrue);
    });
  });
}
