import 'package:flutter/material.dart';
import 'package:pauza/src/core/common/extensions.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/home/model/home_dashboard_metrics.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class HomeStatsPill extends StatelessWidget {
  const HomeStatsPill({required this.metrics, super.key});

  final HomeDashboardMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final streakLabel = metrics.streakDays == null ? '--' : l10n.homeDayStreakLabel(metrics.streakDays!);
    final durationLabel = metrics.focusedDuration?.formatDurationLabel(l10n) ?? '--';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(PauzaCornerRadius.full),
        border: Border.all(color: context.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: PauzaSpacing.large, vertical: PauzaSpacing.regular),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: PauzaSpacing.small,
          children: <Widget>[
            Icon(Icons.local_fire_department, size: PauzaIconSizes.small, color: context.colorScheme.primary),

            Text(streakLabel, style: context.textTheme.titleMedium),

            SizedBox(height: 16, child: VerticalDivider(width: 20, thickness: 1, color: context.colorScheme.outlineVariant)),
            Icon(Icons.timer_outlined, size: PauzaIconSizes.small, color: context.colorScheme.primary),

            Text(durationLabel, style: context.textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
