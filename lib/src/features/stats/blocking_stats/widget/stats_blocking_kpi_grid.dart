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

    final items = <({String label, String value})>[
      (label: l10n.statsBlockingCurrentStreak, value: l10n.statsBlockingDaysValue(snapshot.currentStreakDays)),
      (label: l10n.statsBlockingLongestStreak, value: l10n.statsBlockingDaysValue(snapshot.longestStreakDays)),
      (
        label: l10n.statsBlockingAvgSessionDuration,
        value: snapshot.averageRestrictionSessionDuration.formatDurationLabel(l10n),
      ),
      (
        label: l10n.statsBlockingLongestSessionDuration,
        value: snapshot.longestRestrictionSessionDuration.formatDurationLabel(l10n),
      ),
      (
        label: l10n.statsBlockingAvgPausesPerSession,
        value: _avgPausesPerSession(context, snapshot.averagePausesPerSession),
      ),
      (label: l10n.statsBlockingAvgPauseDuration, value: snapshot.averagePauseDuration.formatDurationLabel(l10n)),
    ];

    return StatsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: PauzaSpacing.medium,
        children: <Widget>[
          StatsSectionHeader(label: l10n.statsBlockingKpis),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 560 ? 2 : 1;
              final tileWidth = columns == 1
                  ? constraints.maxWidth
                  : (constraints.maxWidth - PauzaSpacing.medium) / columns;

              return Wrap(
                spacing: PauzaSpacing.medium,
                runSpacing: PauzaSpacing.medium,
                children: items.map((item) {
                  return SizedBox(
                    width: tileWidth,
                    child: StatsMetricTile(label: item.label, value: item.value),
                  );
                }).toList(growable: false),
              );
            },
          ),
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
