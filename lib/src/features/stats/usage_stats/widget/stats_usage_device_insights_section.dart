import 'package:flutter/material.dart';
import 'package:pauza/src/core/common/extensions.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/stats/usage_stats/model/device_event_snapshot.dart';
import 'package:pauza/src/features/stats/common/widget/stats_kpi_card.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class StatsUsageDeviceInsightsSection extends StatelessWidget {
  const StatsUsageDeviceInsightsSection({required this.snapshot, super.key});

  final DeviceEventSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    final avgSession = snapshot.screenOnCount > 0
        ? Duration(milliseconds: snapshot.totalScreenOnTime.inMilliseconds ~/ snapshot.screenOnCount)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.statsDeviceInsights, style: textTheme.titleLarge),
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
                  child: StatsKpiCard(label: l10n.statsUnlockCount, value: snapshot.unlockCount.toString()),
                ),
                SizedBox(
                  width: cardWidth,
                  child: StatsKpiCard(label: l10n.statsPickupCount, value: snapshot.screenOnCount.toString()),
                ),
                SizedBox(
                  width: cardWidth,
                  child: StatsKpiCard(
                    label: l10n.statsScreenOnDuration,
                    value: snapshot.totalScreenOnTime.formatDurationLabel(l10n),
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: StatsKpiCard(label: l10n.statsAvgScreenOnSession, value: avgSession.formatDurationLabel(l10n)),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
