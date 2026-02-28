import 'package:flutter/material.dart';
import 'package:pauza/src/core/common/extensions.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/stats/blocking_stats/model/blocking_stats_snapshot.dart';
import 'package:pauza/src/features/stats/common/widget/stats_kpi_card.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class StatsBlockingKpiSection extends StatelessWidget {
  const StatsBlockingKpiSection({required this.snapshot, super.key});

  final BlockingStatsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.statsBlockingKpis, style: textTheme.titleLarge),
        const SizedBox(height: PauzaSpacing.medium),
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = (constraints.maxWidth - PauzaSpacing.small) / 2;

            return Wrap(
              spacing: PauzaSpacing.small,
              runSpacing: PauzaSpacing.small,
              children: [
                SizedBox(
                  width: cardWidth,
                  child: StatsKpiCard(
                    label: l10n.statsBlockingCurrentStreak,
                    value: l10n.statsBlockingDaysValue(snapshot.currentStreakDays),
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: StatsKpiCard(
                    label: l10n.statsBlockingLongestStreak,
                    value: l10n.statsBlockingDaysValue(snapshot.longestStreakDays),
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: StatsKpiCard(
                    label: l10n.statsBlockingAvgSessionDuration,
                    value: snapshot.averageRestrictionSessionDuration.formatDurationLabel(l10n),
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: StatsKpiCard(
                    label: l10n.statsBlockingLongestSessionDuration,
                    value: snapshot.longestRestrictionSessionDuration.formatDurationLabel(l10n),
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: StatsKpiCard(
                    label: l10n.statsBlockingAvgPausesPerSession,
                    value: l10n.statsBlockingPerSessionValue(
                      snapshot.averagePausesPerSession?.toStringAsFixed(1) ?? '--',
                    ),
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: StatsKpiCard(
                    label: l10n.statsBlockingAvgPauseDuration,
                    value: snapshot.averagePauseDuration.formatDurationLabel(l10n),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
