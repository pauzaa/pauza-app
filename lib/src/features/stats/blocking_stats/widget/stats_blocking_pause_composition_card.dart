import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pauza/src/core/common/extensions.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/stats/blocking_stats/model/blocking_stats_snapshot.dart';
import 'package:pauza/src/features/stats/usage_stats/widget/stats_card.dart';
import 'package:pauza/src/features/stats/usage_stats/widget/stats_section_header.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class StatsBlockingPauseCompositionCard extends StatelessWidget {
  const StatsBlockingPauseCompositionCard({required this.snapshot, super.key});

  final BlockingStatsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final effectiveMs = snapshot.totalEffectiveBlockedDuration.inMilliseconds.toDouble();
    final pausedMs = snapshot.totalPausedDuration.inMilliseconds.toDouble();
    final sum = effectiveMs + pausedMs;

    return StatsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: PauzaSpacing.medium,
        children: <Widget>[
          StatsSectionHeader(label: context.l10n.statsBlockingPauseComposition),
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                startDegreeOffset: -90,
                centerSpaceRadius: 60,
                sectionsSpace: 0,
                borderData: FlBorderData(show: false),
                pieTouchData: PieTouchData(enabled: false),
                sections: <PieChartSectionData>[
                  PieChartSectionData(
                    value: sum == 0 ? 1 : effectiveMs,
                    color: context.colorScheme.primary,
                    title: '',
                    radius: 28,
                  ),
                  PieChartSectionData(
                    value: sum == 0 ? 1 : pausedMs,
                    color: context.colorScheme.tertiary,
                    title: '',
                    radius: 28,
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _PauseCompositionLegend(
                context: context,
                color: context.colorScheme.primary,
                label: context.l10n.statsBlockingEffectiveDuration,
                value: snapshot.totalEffectiveBlockedDuration.formatDurationLabel(context.l10n),
              ),
              _PauseCompositionLegend(
                context: context,
                color: context.colorScheme.tertiary,
                label: context.l10n.statsBlockingPausedDuration,
                value: snapshot.totalPausedDuration.formatDurationLabel(context.l10n),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PauseCompositionLegend extends StatelessWidget {
  const _PauseCompositionLegend({required this.context, required this.color, required this.label, required this.value});

  final BuildContext context;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: <Widget>[
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(PauzaCornerRadius.full)),
          ),
          const SizedBox(width: PauzaSpacing.small),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: context.textTheme.labelMedium?.copyWith(color: context.colorScheme.onSurfaceVariant),
                ),
                Text(value, style: context.textTheme.titleSmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
