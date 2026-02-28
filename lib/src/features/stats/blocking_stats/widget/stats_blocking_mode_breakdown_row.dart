import 'package:flutter/material.dart';
import 'package:pauza/src/core/common/extensions.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/stats/blocking_stats/model/mode_blocking_breakdown.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class StatsBlockingModeBreakdownRow extends StatelessWidget {
  const StatsBlockingModeBreakdownRow({required this.breakdown, super.key});

  final ModeBlockingBreakdown breakdown;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: PauzaSpacing.small),
      child: Row(
        children: [
          Expanded(child: Text(breakdown.modeTitle, style: textTheme.bodyMedium)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                l10n.statsBlockingSessionCountValue(breakdown.completedSessionsCount),
                style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              Text(
                breakdown.totalEffectiveBlockedDuration.formatDurationLabel(l10n),
                style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
