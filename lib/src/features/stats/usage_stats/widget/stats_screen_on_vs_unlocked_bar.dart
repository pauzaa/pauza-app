import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pauza/src/core/common/extensions.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class StatsScreenOnVsUnlockedBar extends StatelessWidget {
  const StatsScreenOnVsUnlockedBar({required this.screenOnDuration, required this.unlockedDuration, super.key});

  final Duration screenOnDuration;
  final Duration unlockedDuration;

  @override
  Widget build(BuildContext context) {
    final denominator = math.max(screenOnDuration.inMilliseconds, 1);
    final normalizedUnlocked = unlockedDuration.inMilliseconds / denominator;
    final unlockedFraction = normalizedUnlocked.clamp(0.0, 1.0);
    final unlockedFlex = math.max(1, (unlockedFraction * 1000).round());
    final remainingFlex = math.max(1, ((1 - unlockedFraction) * 1000).round());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          context.l10n.statsScreenOnVsUnlocked,
          style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: PauzaSpacing.small),
        ClipRRect(
          borderRadius: BorderRadius.circular(PauzaCornerRadius.small),
          child: SizedBox(
            height: 12,
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: unlockedFlex,
                  child: DecoratedBox(decoration: BoxDecoration(color: context.colorScheme.primary)),
                ),
                Expanded(
                  flex: remainingFlex,
                  child: DecoratedBox(decoration: BoxDecoration(color: context.colorScheme.outlineVariant)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: PauzaSpacing.small),
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                '${context.l10n.statsScreenOnDuration}: '
                '${screenOnDuration.formatDurationLabel(context.l10n)}',
                style: context.textTheme.bodyMedium,
              ),
            ),
            Expanded(
              child: Text(
                '${context.l10n.statsUnlockedDuration}: '
                '${unlockedDuration.formatDurationLabel(context.l10n)}',
                style: context.textTheme.bodyMedium,
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
