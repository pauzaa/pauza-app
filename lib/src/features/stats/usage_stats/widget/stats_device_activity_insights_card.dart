import 'package:flutter/material.dart';
import 'package:pauza/src/core/common/extensions.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/stats/usage_stats/model/device_usage_insights.dart';
import 'package:pauza/src/features/stats/usage_stats/widget/stats_card.dart';
import 'package:pauza/src/features/stats/usage_stats/widget/stats_metric_tile.dart';
import 'package:pauza/src/features/stats/usage_stats/widget/stats_screen_on_vs_unlocked_bar.dart';
import 'package:pauza/src/features/stats/usage_stats/widget/stats_section_header.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class StatsDeviceActivityInsightsCard extends StatelessWidget {
  const StatsDeviceActivityInsightsCard({required this.insights, super.key});

  final DeviceUsageInsights insights;

  @override
  Widget build(BuildContext context) {
    final averageSession = insights.screenOnSessionAverage;
    final averageSessionText = averageSession == null ? '-' : averageSession.formatDurationLabel(context.l10n);

    return StatsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          StatsSectionHeader(label: context.l10n.statsDeviceInsights),
          const SizedBox(height: PauzaSpacing.medium),
          LayoutBuilder(
            builder: (context, constraints) {
              final tileWidth = constraints.maxWidth < 560
                  ? constraints.maxWidth
                  : (constraints.maxWidth - PauzaSpacing.medium) / 2;

              return Wrap(
                spacing: PauzaSpacing.medium,
                runSpacing: PauzaSpacing.medium,
                children: <Widget>[
                  SizedBox(
                    width: tileWidth,
                    child: StatsMetricTile(label: context.l10n.statsUnlockCount, value: '${insights.unlockCount}'),
                  ),
                  SizedBox(
                    width: tileWidth,
                    child: StatsMetricTile(
                      label: context.l10n.statsUnlocksPerDay,
                      value: context.l10n.statsPerDayValue(insights.unlocksPerDayAverage.toStringAsFixed(1)),
                    ),
                  ),
                  SizedBox(
                    width: tileWidth,
                    child: StatsMetricTile(label: context.l10n.statsPickupCount, value: '${insights.pickupCount}'),
                  ),
                  SizedBox(
                    width: tileWidth,
                    child: StatsMetricTile(label: context.l10n.statsAvgScreenOnSession, value: averageSessionText),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: PauzaSpacing.large),
          StatsScreenOnVsUnlockedBar(
            screenOnDuration: insights.screenOnDuration,
            unlockedDuration: insights.unlockedDuration,
          ),
        ],
      ),
    );
  }
}
