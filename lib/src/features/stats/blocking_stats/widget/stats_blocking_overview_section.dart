import 'package:flutter/material.dart';
import 'package:pauza/src/core/common/extensions.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/stats/blocking_stats/model/blocking_stats_snapshot.dart';
import 'package:pauza/src/features/stats/common/widget/stats_kpi_card.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class StatsBlockingOverviewSection extends StatelessWidget {
  const StatsBlockingOverviewSection({required this.snapshot, super.key});

  final BlockingStatsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.statsBlockingOverview, style: textTheme.titleLarge),
        const SizedBox(height: PauzaSpacing.medium),
        Row(
          children: [
            Expanded(
              child: StatsKpiCard(
                label: l10n.statsBlockingCompletedSessions,
                value: l10n.statsBlockingSessionCountValue(snapshot.completedSessionsCount),
              ),
            ),
            const SizedBox(width: PauzaSpacing.small),
            Expanded(
              child: StatsKpiCard(
                label: l10n.statsBlockingEffectiveDuration,
                value: snapshot.totalEffectiveBlockedDuration.formatDurationLabel(l10n),
              ),
            ),
            const SizedBox(width: PauzaSpacing.small),
            Expanded(
              child: StatsKpiCard(
                label: l10n.statsBlockingPausedDuration,
                value: snapshot.totalPausedDuration.formatDurationLabel(l10n),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
