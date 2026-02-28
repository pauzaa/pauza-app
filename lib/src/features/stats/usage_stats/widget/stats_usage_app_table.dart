import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/stats/usage_stats/model/app_usage_entry.dart';
import 'package:pauza/src/features/stats/usage_stats/widget/stats_usage_app_row.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class StatsUsageAppTable extends StatelessWidget {
  const StatsUsageAppTable({required this.appUsageEntries, super.key});

  final IList<AppUsageEntry> appUsageEntries;

  static const int _maxEntries = 10;

  @override
  Widget build(BuildContext context) {
    if (appUsageEntries.isEmpty) {
      return const SizedBox.shrink();
    }

    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final displayedEntries = appUsageEntries.take(_maxEntries);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.statsAppUsage, style: textTheme.titleLarge),
        const SizedBox(height: PauzaSpacing.small),
        for (final entry in displayedEntries) StatsUsageAppRow(entry: entry),
      ],
    );
  }
}
