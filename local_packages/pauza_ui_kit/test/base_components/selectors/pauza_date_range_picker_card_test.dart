import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

void main() {
  testWidgets('shifts date range by inclusive span with arrows', (tester) async {
    var selected = DateTimeRange(start: DateTime(2025), end: DateTime(2025, 1, 14));

    await tester.pumpWidget(
      MaterialApp(
        theme: PauzaTheme.dark,
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return PauzaDateRangePickerCard(
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
    expect(selected.end, DateTime(2025, 1, 28, 23, 59, 59, 999));

    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pump();

    expect(selected.start, DateTime(2025));
    expect(selected.end, DateTime(2025, 1, 14, 23, 59, 59, 999));
  });

  testWidgets('caps right shift at max date', (tester) async {
    var selected = DateTimeRange(start: DateTime(2025, 2, 9), end: DateTime(2025, 2, 15));

    await tester.pumpWidget(
      MaterialApp(
        theme: PauzaTheme.dark,
        home: Scaffold(
          body: PauzaDateRangePickerCard(
            selectedRange: selected,
            minDate: DateTime(2024),
            maxDate: DateTime(2025, 2, 16),
            rangeTextBuilder: (_) => 'range',
            onRangeChanged: (range) {
              selected = range;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pump();

    expect(selected.start, DateTime(2025, 2, 10));
    expect(selected.end, DateTime(2025, 2, 16, 23, 59, 59, 999));
  });

  testWidgets('caps left shift at min date', (tester) async {
    var selected = DateTimeRange(start: DateTime(2025, 2, 2), end: DateTime(2025, 2, 8));

    await tester.pumpWidget(
      MaterialApp(
        theme: PauzaTheme.dark,
        home: Scaffold(
          body: PauzaDateRangePickerCard(
            selectedRange: selected,
            minDate: DateTime(2025, 2),
            maxDate: DateTime(2025, 12, 31),
            rangeTextBuilder: (_) => 'range',
            onRangeChanged: (range) {
              selected = range;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pump();

    expect(selected.start, DateTime(2025, 2));
    expect(selected.end, DateTime(2025, 2, 7, 23, 59, 59, 999));
  });

  testWidgets('supports nullable min and max dates', (tester) async {
    var selected = DateTimeRange(start: DateTime(2025), end: DateTime(2025, 1, 14));

    await tester.pumpWidget(
      MaterialApp(
        theme: PauzaTheme.dark,
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return PauzaDateRangePickerCard(
                selectedRange: selected,
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
    expect(selected.end, DateTime(2025, 1, 28, 23, 59, 59, 999));

    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pump();

    expect(selected.start, DateTime(2025));
    expect(selected.end, DateTime(2025, 1, 14, 23, 59, 59, 999));
  });
}
