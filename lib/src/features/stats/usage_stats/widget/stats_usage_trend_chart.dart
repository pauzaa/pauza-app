import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pauza/src/core/common/extensions.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/stats/usage_stats/model/daily_usage_point.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class StatsUsageTrendChart extends StatelessWidget {
  const StatsUsageTrendChart({
    required this.dailyTrend,
    this.animationDuration = const Duration(milliseconds: 150),
    super.key,
  });

  final IList<DailyUsagePoint> dailyTrend;
  final Duration animationDuration;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (dailyTrend.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxHours = dailyTrend.map((p) => p.totalScreenTime.inMinutes / 60).reduce((a, b) => a > b ? a : b);
    final useMinutes = maxHours < 1.0;
    final double maxY;
    if (useMinutes) {
      final maxMinutes = dailyTrend.map((p) => p.totalScreenTime.inMinutes.toDouble()).reduce((a, b) => a > b ? a : b);
      maxY = (maxMinutes * 1.2).ceilToDouble().clamp(1.0, double.infinity);
    } else {
      maxY = (maxHours * 1.2).ceilToDouble().clamp(1.0, double.infinity);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.usageTrend, style: textTheme.titleLarge),
        const SizedBox(height: PauzaSpacing.medium),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final point = dailyTrend[group.x];
                    return BarTooltipItem(
                      point.totalScreenTime.formatDurationLabel(l10n),
                      textTheme.bodySmall?.copyWith(color: colorScheme.onPrimary) ?? const TextStyle(),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                rightTitles: const AxisTitles(),
                topTitles: const AxisTitles(),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    getTitlesWidget: (value, meta) {
                      if (value == 0) return const SizedBox.shrink();
                      return Text(
                        useMinutes ? '${value.toInt()}m' : '${value.toInt()}h',
                        style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= dailyTrend.length) {
                        return const SizedBox.shrink();
                      }
                      final date = dailyTrend[index].localDay.localDate;
                      if (date == null) return const SizedBox.shrink();

                      final count = dailyTrend.length;
                      String label;
                      if (count <= 7) {
                        label = DateFormat.E().format(date);
                      } else if (count <= 14) {
                        label = DateFormat('MMM d').format(date);
                      } else {
                        if (index % 7 != 0) return const SizedBox.shrink();
                        label = DateFormat('MMM d').format(date);
                      }

                      return SideTitleWidget(
                        meta: meta,
                        child: Text(
                          label,
                          style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant, fontSize: 10),
                        ),
                      );
                    },
                  ),
                ),
              ),
              gridData: FlGridData(
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) => FlLine(color: colorScheme.outlineVariant, strokeWidth: 0.5),
              ),
              borderData: FlBorderData(show: false),
              barGroups: [
                for (var i = 0; i < dailyTrend.length; i++)
                  BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: useMinutes
                            ? dailyTrend[i].totalScreenTime.inMinutes.toDouble()
                            : dailyTrend[i].totalScreenTime.inMinutes / 60,
                        color: colorScheme.primary,
                        width: dailyTrend.length <= 7
                            ? 20
                            : dailyTrend.length <= 14
                            ? 12
                            : 6,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(PauzaCornerRadius.xxSmall)),
                      ),
                    ],
                  ),
              ],
            ),
            duration: animationDuration,
          ),
        ),
      ],
    );
  }
}
