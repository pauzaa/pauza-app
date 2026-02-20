import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pauza/src/features/stats/usage_stats/model/usage_category_bucket.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class StatsDonutChart extends StatelessWidget {
  const StatsDonutChart({required this.buckets, super.key});

  final Map<UsageCategoryBucket, Duration> buckets;

  @override
  Widget build(BuildContext context) {
    final total = buckets.values.fold<Duration>(Duration.zero, (sum, duration) => sum + duration);

    final sections = <PieChartSectionData>[
      _section(context, UsageCategoryBucket.social, total),
      _section(context, UsageCategoryBucket.productivity, total),
      _section(context, UsageCategoryBucket.other, total),
    ];

    return AspectRatio(
      aspectRatio: 1,
      child: PieChart(
        PieChartData(
          startDegreeOffset: -90,
          centerSpaceRadius: 92,
          sectionsSpace: 0,
          borderData: FlBorderData(show: false),
          pieTouchData: PieTouchData(enabled: false),
          sections: sections,
        ),
      ),
    );
  }

  PieChartSectionData _section(BuildContext context, UsageCategoryBucket bucket, Duration total) {
    final value = buckets[bucket]?.inMilliseconds.toDouble() ?? 0;
    final fallback = total.inMilliseconds == 0 ? 1.0 : value;

    return PieChartSectionData(
      value: fallback,
      color: bucket.getColorForFonutBucket(context.colorScheme),
      title: '',
      radius: 28,
    );
  }
}
