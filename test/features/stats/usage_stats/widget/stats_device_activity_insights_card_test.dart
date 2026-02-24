import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/features/stats/usage_stats/model/device_usage_insights.dart';
import 'package:pauza/src/features/stats/usage_stats/widget/stats_device_activity_insights_card.dart';

import '../helpers/pump_stats_widget.dart';

void main() {
  testWidgets('renders metrics and dash when avg session is null', (tester) async {
    await pumpStatsWidget(
      tester,
      const StatsDeviceActivityInsightsCard(
        insights: DeviceUsageInsights(
          unlockCount: 3,
          lockCount: 3,
          pickupCount: 0,
          screenOnDuration: Duration.zero,
          unlockedDuration: Duration.zero,
          screenOnSessionAverage: null,
          unlocksPerDayAverage: 1.2,
          firstUnlockAt: null,
          lastUnlockAt: null,
          source: DeviceUsageInsightsSource.eventStats,
        ),
      ),
    );

    expect(find.text('DEVICE INSIGHTS'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('-'), findsOneWidget);
    expect(find.text('Screen-on vs unlocked'), findsOneWidget);
  });
}
