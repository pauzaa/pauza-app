import 'package:flutter/material.dart';
import 'package:pauza/src/core/common/extensions.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/stats/usage_stats/model/usage_stats_snapshot.dart';
import 'package:pauza/src/features/stats/usage_stats/widget/stats_usage_kpi_card.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class StatsUsageKpiRow extends StatelessWidget {
  const StatsUsageKpiRow({required this.snapshot, super.key});

  final UsageStatsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: StatsUsageKpiCard(label: l10n.totalTime, value: snapshot.totalScreenTime.formatDurationLabel(l10n)),
        ),
        const SizedBox(width: PauzaSpacing.small),
        Expanded(
          child: StatsUsageKpiCard(
            label: l10n.statsDailyAverage,
            value: snapshot.averageDailyScreenTime.formatDurationLabel(l10n),
          ),
        ),
        const SizedBox(width: PauzaSpacing.small),
        Expanded(
          child: StatsUsageKpiCard(
            label: l10n.statsUsageTableLaunchesColumn,
            value: snapshot.totalLaunchCount.toString(),
          ),
        ),
      ],
    );
  }
}
