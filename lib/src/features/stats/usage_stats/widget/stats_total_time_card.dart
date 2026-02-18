import 'package:flutter/material.dart';
import 'package:pauza/src/core/common/extensions.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/stats/usage_stats/model/usage_summary.dart';
import 'package:pauza/src/features/stats/usage_stats/widget/stats_donut_chart.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class StatsTotalTimeCard extends StatelessWidget {
  const StatsTotalTimeCard({required this.summary, super.key});

  final UsageSummary summary;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(PauzaCornerRadius.large),
        border: Border.all(color: context.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(PauzaSpacing.large),
        child: Column(
          spacing: PauzaSpacing.medium,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    context.l10n.totalTime.toUpperCase(),
                    style: context.textTheme.headlineSmall?.copyWith(color: context.colorScheme.onSurfaceVariant, letterSpacing: 2),
                  ),
                ),
                if (summary.deltaPercent case final deltaPercent?)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: context.colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(PauzaCornerRadius.small),
                      border: Border.all(color: context.colorScheme.primary.withValues(alpha: 0.5)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: PauzaSpacing.medium, vertical: PauzaSpacing.small),
                      child: Text(
                        context.l10n.statsDeltaVsLastPeriod(_formatDelta(deltaPercent)),
                        style: context.textTheme.titleMedium?.copyWith(color: context.colorScheme.primary, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
              ],
            ),
            Stack(
              alignment: Alignment.center,
              children: <Widget>[
                StatsDonutChart(buckets: summary.buckets),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      summary.dailyAverage.formatDurationLabel(context.l10n),
                      style: context.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      context.l10n.statsDailyAverage,
                      style: context.textTheme.headlineSmall?.copyWith(color: context.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _LegendItem(color: context.colorScheme.primary, label: context.l10n.statsBucketSocial),
                _LegendItem(color: context.colorScheme.onSurfaceVariant, label: context.l10n.statsBucketProductivity),
                _LegendItem(color: context.colorScheme.outline, label: context.l10n.statsBucketOther),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDelta(double value) {
    final rounded = value.round();
    if (rounded > 0) {
      return '+$rounded%';
    }
    return '$rounded%';
  }
}

final class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: PauzaSpacing.small,
      children: <Widget>[
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        Text(label, style: context.textTheme.titleMedium),
      ],
    );
  }
}
