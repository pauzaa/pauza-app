import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

void main() {
  testWidgets('shifts date range by inclusive span with arrows', (
    tester,
  ) async {
    var selected = DateTimeRange(
      start: DateTime(2025),
      end: DateTime(2025, 1, 14),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: PauzaTheme.dark,
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return PauzaDateRangePickerCard(
                title: 'This Week',
                selectedRange: selected,
                minDate: DateTime(2024),
                maxDate: DateTime(2026),
                rangeTextBuilder: (_) => 'range',
                onRangeChanged: (range) {
                  setState(() {
                    selected = range;
                  });
                },
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pump();

    expect(selected.start, DateTime(2025, 1, 15));
    expect(selected.end, DateTime(2025, 1, 28));

    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pump();

    expect(selected.start, DateTime(2025));
    expect(selected.end, DateTime(2025, 1, 14));
  });

  testWidgets('disables right arrow when shift exceeds max date', (
    tester,
  ) async {
    final selected = DateTimeRange(
      start: DateTime(2025, 1, 20),
      end: DateTime(2025, 1, 26),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: PauzaTheme.dark,
        home: Scaffold(
          body: PauzaDateRangePickerCard(
            title: 'This Week',
            selectedRange: selected,
            minDate: DateTime(2024),
            maxDate: DateTime(2025, 1, 31),
            rangeTextBuilder: (_) => 'range',
            onRangeChanged: (_) {},
          ),
        ),
      ),
    );

    final button = tester.widgetList<IconButton>(find.byType(IconButton)).last;
    expect(button.onPressed, isNull);
  });
}
