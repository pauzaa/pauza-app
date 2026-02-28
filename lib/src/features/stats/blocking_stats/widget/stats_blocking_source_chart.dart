import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pauza/src/core/common/extensions.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/stats/blocking_stats/model/session_source.dart';
import 'package:pauza/src/features/stats/blocking_stats/model/source_blocking_snapshot.dart';
import 'package:pauza/src/features/stats/blocking_stats/widget/stats_blocking_source_legend_item.dart';
import 'package:pauza/src/features/stats/common/widget/stats_chart_colors.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class StatsBlockingSourceChart extends StatelessWidget {
  const StatsBlockingSourceChart({
    required this.sourceBreakdown,
    this.animationDuration = const Duration(milliseconds: 150),
    super.key,
  });

  final SourceBlockingSnapshot sourceBreakdown;
  final Duration animationDuration;

  @override
  Widget build(BuildContext context) {
    if (sourceBreakdown.isEmpty) {
      return const SizedBox.shrink();
    }

    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.statsBlockingBySource, style: textTheme.titleLarge),
        const SizedBox(height: PauzaSpacing.medium),
        Row(
          children: [
            SizedBox(
              width: 150,
              height: 150,
              child: PieChart(
                PieChartData(
                  sections: [
                    for (var i = 0; i < sourceBreakdown.breakdowns.length; i++)
                      PieChartSectionData(
                        value: sourceBreakdown.breakdowns[i].totalEffectiveBlockedDuration.inMinutes.toDouble(),
                        color: StatsChartColors.colorAt(i),
                        radius: 60,
                        showTitle: false,
                      ),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 0,
                ),
                duration: animationDuration,
              ),
            ),
            const SizedBox(width: PauzaSpacing.medium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < sourceBreakdown.breakdowns.length; i++)
                    StatsBlockingSourceLegendItem(
                      color: StatsChartColors.colorAt(i),
                      label: _resolveSourceLabel(sourceBreakdown.breakdowns[i].source, l10n),
                      value: sourceBreakdown.breakdowns[i].totalEffectiveBlockedDuration.formatDurationLabel(l10n),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _resolveSourceLabel(SessionSource source, AppLocalizations l10n) {
    return switch (source) {
      SessionSource.manual => l10n.statsBlockingManualSource,
      SessionSource.schedule => l10n.statsBlockingScheduledSource,
    };
  }
}
