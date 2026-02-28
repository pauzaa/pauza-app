import 'package:flutter/material.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/stats/blocking_stats/model/mode_blocking_snapshot.dart';
import 'package:pauza/src/features/stats/blocking_stats/widget/stats_blocking_mode_breakdown_row.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class StatsBlockingModeBreakdownSection extends StatelessWidget {
  const StatsBlockingModeBreakdownSection({required this.modeBreakdown, super.key});

  final ModeBlockingSnapshot modeBreakdown;

  @override
  Widget build(BuildContext context) {
    if (modeBreakdown.isEmpty) {
      return const SizedBox.shrink();
    }

    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(l10n.statsBlockingByMode, style: textTheme.titleLarge),
        const SizedBox(height: PauzaSpacing.small),
        for (final breakdown in modeBreakdown.breakdowns) StatsBlockingModeBreakdownRow(breakdown: breakdown),
      ],
    );
  }
}
