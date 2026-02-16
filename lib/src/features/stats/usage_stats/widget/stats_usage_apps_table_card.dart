import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pauza/src/core/common/extensions.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class StatsUsageAppsTableCard extends StatelessWidget {
  const StatsUsageAppsTableCard({required this.usageStats, super.key});

  final IList<UsageStats> usageStats;

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
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: PauzaSpacing.medium,
          children: <Widget>[
            Text(
              context.l10n.statsAppUsage.toUpperCase(),
              style: context.textTheme.headlineSmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
                letterSpacing: 2,
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: <DataColumn>[
                  DataColumn(label: Text(context.l10n.statsUsageTableAppColumn)),
                  DataColumn(label: Text(context.l10n.statsUsageTableUsageColumn)),
                  DataColumn(label: Text(context.l10n.statsUsageTableLaunchesColumn)),
                  DataColumn(label: Text(context.l10n.statsUsageTableLastUsedColumn)),
                ],
                rows: usageStats
                    .map((stat) {
                      return DataRow(
                        cells: <DataCell>[
                          DataCell(Text(stat.appInfo.name)),
                          DataCell(Text(stat.totalDuration.formatDurationLabel(context.l10n))),
                          DataCell(Text('${stat.totalLaunchCount}')),
                          DataCell(
                            Text(
                              stat.lastTimeUsed == null
                                  ? '-'
                                  : DateFormat('MMM d, HH:mm').format(stat.lastTimeUsed!),
                            ),
                          ),
                        ],
                      );
                    })
                    .toList(growable: false),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
