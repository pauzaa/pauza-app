import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/features/stats/usage_stats/widget/stats_screen_on_vs_unlocked_bar.dart';

import '../helpers/pump_stats_widget.dart';

void main() {
  testWidgets('renders without crashing for 0/0 durations', (tester) async {
    await pumpStatsWidget(
      tester,
      const StatsScreenOnVsUnlockedBar(screenOnDuration: Duration.zero, unlockedDuration: Duration.zero),
    );

    expect(find.text('Screen-on vs unlocked'), findsOneWidget);
    expect(find.textContaining('0h 0m'), findsNWidgets(2));
  });

  testWidgets('renders full unlocked segment when unlocked equals screen-on', (tester) async {
    await pumpStatsWidget(
      tester,
      const StatsScreenOnVsUnlockedBar(
        screenOnDuration: Duration(minutes: 30),
        unlockedDuration: Duration(minutes: 30),
      ),
    );

    expect(find.textContaining('0h 30m'), findsNWidgets(2));
  });

  testWidgets('clamps unlocked duration safely when unlocked exceeds screen-on', (tester) async {
    await pumpStatsWidget(
      tester,
      const StatsScreenOnVsUnlockedBar(
        screenOnDuration: Duration(minutes: 10),
        unlockedDuration: Duration(minutes: 30),
      ),
    );

    expect(find.textContaining('0h 10m'), findsOneWidget);
    expect(find.textContaining('0h 30m'), findsOneWidget);
  });

  testWidgets('renders full locked segment when unlocked is zero and screen-on is non-zero', (tester) async {
    await pumpStatsWidget(
      tester,
      const StatsScreenOnVsUnlockedBar(screenOnDuration: Duration(minutes: 20), unlockedDuration: Duration.zero),
    );

    expect(find.textContaining('0h 20m'), findsOneWidget);
    expect(find.textContaining('0h 0m'), findsOneWidget);
  });
}
