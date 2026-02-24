import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/stats/blocking_stats/model/blocking_stats_snapshot.dart';
import 'package:pauza/src/features/stats/usage_stats/widget/stats_card.dart';
import 'package:pauza/src/features/stats/usage_stats/widget/stats_section_header.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class StatsBlockingDailyTrendCard extends StatelessWidget {
  const StatsBlockingDailyTrendCard({required this.snapshot, super.key});

  final BlockingStatsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final points = snapshot.dailyTrend;

    return StatsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: PauzaSpacing.medium,
        children: <Widget>[
          StatsSectionHeader(label: context.l10n.statsBlockingDailyTrend),
          if (points.isEmpty)
            Text(
              context.l10n.statsBlockingNoData,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.onSurfaceVariant),
            )
          else
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    horizontalInterval: 10,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(color: context.colorScheme.outlineVariant.withValues(alpha: 0.5), strokeWidth: 1);
                    },
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                    leftTitles: const AxisTitles(),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          final index = value.toInt();
                          if (index < 0 || index >= points.length) {
                            return const SizedBox.shrink();
                          }

                          final day = points[index].localDay.localDate;
                          if (day == null) {
                            return const SizedBox.shrink();
                          }

                          return Padding(
                            padding: const EdgeInsets.only(top: PauzaSpacing.small),
                            child: Text(
                              DateFormat('MMMd').format(day),
                              style: context.textTheme.labelMedium?.copyWith(
                                color: context.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: List.generate(points.length, (index) {
                    return BarChartGroupData(
                      x: index,
                      barRods: <BarChartRodData>[
                        BarChartRodData(
                          toY: points[index].effectiveDuration.inMinutes.toDouble(),
                          color: context.colorScheme.primary,
                          width: 14,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(PauzaCornerRadius.small)),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
