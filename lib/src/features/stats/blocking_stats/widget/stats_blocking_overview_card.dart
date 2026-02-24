import 'package:flutter/material.dart';
import 'package:pauza/src/core/common/extensions.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/stats/blocking_stats/model/blocking_stats_snapshot.dart';
import 'package:pauza/src/features/stats/usage_stats/widget/stats_card.dart';
import 'package:pauza/src/features/stats/usage_stats/widget/stats_metric_tile.dart';
import 'package:pauza/src/features/stats/usage_stats/widget/stats_section_header.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class StatsBlockingOverviewCard extends StatelessWidget {
  const StatsBlockingOverviewCard({required this.snapshot, super.key});

  final BlockingStatsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final label = l10n.statsBlockingPausedDuration;
    final value = snapshot.totalPausedDuration.formatDurationLabel(l10n);
    final label2 = l10n.statsBlockingEffectiveDuration;
    final value2 = snapshot.totalEffectiveBlockedDuration.formatDurationLabel(l10n);
    final label3 = l10n.statsBlockingCompletedSessions;
    final value3 = l10n.statsBlockingSessionCountValue(snapshot.completedSessionsCount);
    return StatsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: PauzaSpacing.medium,
        children: <Widget>[
          StatsSectionHeader(label: l10n.statsBlockingOverview),
          StatsMetricTile(label: label3, value: value3),
          StatsMetricTile(label: label2, value: value2),
          StatsMetricTile(label: label, value: value),
        ],
      ),
    );
  }
}
