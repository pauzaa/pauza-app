import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pauza/src/core/common/extensions.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/stats/blocking_stats/model/blocking_stats_snapshot.dart';
import 'package:pauza/src/features/stats/usage_stats/widget/stats_card.dart';
import 'package:pauza/src/features/stats/usage_stats/widget/stats_metric_tile.dart';
import 'package:pauza/src/features/stats/usage_stats/widget/stats_section_header.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class StatsBlockingKpiGrid extends StatelessWidget {
  const StatsBlockingKpiGrid({required this.snapshot, super.key});

  final BlockingStatsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final label = l10n.statsBlockingCurrentStreak;
    final value = l10n.statsBlockingDaysValue(snapshot.currentStreakDays);
    final label2 = l10n.statsBlockingLongestStreak;
    final value2 = l10n.statsBlockingDaysValue(snapshot.longestStreakDays);
    final label3 = l10n.statsBlockingAvgSessionDuration;
    final duration3 = snapshot.averageRestrictionSessionDuration;
    final value3 = duration3.formatDurationLabel(context.l10n);
    final label4 = l10n.statsBlockingLongestSessionDuration;
    final duration2 = snapshot.longestRestrictionSessionDuration;
    final value4 = duration2.formatDurationLabel(context.l10n);
    final duration = snapshot.averagePauseDuration;
    return StatsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: PauzaSpacing.medium,
        children: <Widget>[
          StatsSectionHeader(label: l10n.statsBlockingKpis),
          StatsMetricTile(label: label, value: value),
          StatsMetricTile(label: label2, value: value2),
          StatsMetricTile(label: label3, value: value3),
          StatsMetricTile(label: label4, value: value4),
          StatsMetricTile(
            label: l10n.statsBlockingAvgPausesPerSession,
            value: _avgPausesPerSession(context, snapshot.averagePausesPerSession),
          ),
          StatsMetricTile(label: l10n.statsBlockingAvgPauseDuration, value: duration.formatDurationLabel(context.l10n)),
        ],
      ),
    );
  }

  String _avgPausesPerSession(BuildContext context, double? average) {
    if (average == null) {
      return '--';
    }

    final locale = Localizations.localeOf(context).toLanguageTag();
    final formatted = NumberFormat('0.0', locale).format(average);
    return context.l10n.statsBlockingPerSessionValue(formatted);
  }
}
