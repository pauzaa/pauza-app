import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/stats/usage_stats/model/stats_section_status.dart';
import 'package:pauza/src/features/stats/usage_stats/widget/stats_card.dart';
import 'package:pauza/src/features/stats/usage_stats/widget/stats_hourly_heatmap_grid.dart';
import 'package:pauza/src/features/stats/usage_stats/widget/stats_section_header.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class StatsHourlyHeatmapCard extends StatelessWidget {
  const StatsHourlyHeatmapCard({required this.status, required this.heatmap, required this.onRetry, super.key});

  final StatsSectionStatus status;
  final IMap<int, Duration> heatmap;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return StatsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          StatsSectionHeader(label: context.l10n.statsHourlyHeatmap),
          const SizedBox(height: PauzaSpacing.small),
          Text(
            context.l10n.statsHourlyHeatmapSubtitle,
            style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: PauzaSpacing.medium),
          if (status == StatsSectionStatus.loading)
            const SizedBox(height: 164, child: Center(child: CircularProgressIndicator()))
          else if (status == StatsSectionStatus.failure)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(context.l10n.statsInsightLoadFailed, style: context.textTheme.bodyLarge),
                const SizedBox(height: PauzaSpacing.medium),
                PauzaFilledButton(
                  onPressed: onRetry,
                  size: PauzaButtonSize.small,
                  title: Text(context.l10n.retryButton),
                ),
              ],
            )
          else if (status == StatsSectionStatus.empty || status == StatsSectionStatus.initial)
            Text(context.l10n.statsNoInsightData, style: context.textTheme.bodyLarge)
          else ...<Widget>[
            StatsHourlyHeatmapGrid(heatmap: heatmap),
            const SizedBox(height: PauzaSpacing.medium),
            Row(
              children: <Widget>[
                Text(context.l10n.statsHeatmapLegendLow, style: context.textTheme.bodySmall),
                const SizedBox(width: PauzaSpacing.small),
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: <Color>[
                          context.colorScheme.primary.withValues(alpha: 0.12),
                          context.colorScheme.primary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(PauzaCornerRadius.small),
                    ),
                    child: const SizedBox(height: 10),
                  ),
                ),
                const SizedBox(width: PauzaSpacing.small),
                Text(context.l10n.statsHeatmapLegendHigh, style: context.textTheme.bodySmall),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
