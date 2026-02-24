import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/features/stats/usage_stats/model/stats_section_status.dart';
import 'package:pauza/src/features/stats/usage_stats/widget/stats_hourly_heatmap_card.dart';

import '../helpers/pump_stats_widget.dart';

void main() {
  testWidgets('renders 24 hour cells and legend on success', (tester) async {
    final heatmap = IMap<int, Duration>.fromEntries(
      List.generate(24, (index) => MapEntry(index, Duration(minutes: index == 9 ? 60 : 0))),
    );

    await pumpStatsWidget(
      tester,
      StatsHourlyHeatmapCard(status: StatsSectionStatus.success, heatmap: heatmap, onRetry: () {}),
    );

    expect(find.text('HOURLY HEATMAP'), findsOneWidget);
    expect(find.text('00'), findsOneWidget);
    expect(find.text('23'), findsOneWidget);
    expect(find.text('Low'), findsOneWidget);
    expect(find.text('High'), findsOneWidget);
  });

  testWidgets('renders failure state with retry button', (tester) async {
    await pumpStatsWidget(
      tester,
      StatsHourlyHeatmapCard(status: StatsSectionStatus.failure, heatmap: const IMap.empty(), onRetry: () {}),
    );

    expect(find.text('Failed to load this insight.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}
