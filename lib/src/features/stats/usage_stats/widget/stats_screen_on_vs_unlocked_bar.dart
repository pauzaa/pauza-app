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
    final hasAnyDuration = screenOnDuration > Duration.zero || unlockedDuration > Duration.zero;
    final normalizedScreenOnMs = math.max(screenOnDuration.inMilliseconds, 0);
    final normalizedUnlockedMs = math.max(unlockedDuration.inMilliseconds, 0);
    final clampedUnlockedMs = math.min(normalizedUnlockedMs, normalizedScreenOnMs);
    final lockedMs = math.max(normalizedScreenOnMs - clampedUnlockedMs, 0);

    final bar = hasAnyDuration
        ? LayoutBuilder(
            builder: (context, constraints) {
              final totalMs = clampedUnlockedMs + lockedMs;
              if (totalMs <= 0) {
                return DecoratedBox(
                  decoration: BoxDecoration(color: context.colorScheme.surfaceContainerHighest),
                  child: const SizedBox.expand(),
                );
              }

              final unlockedWidth = constraints.maxWidth * (clampedUnlockedMs / totalMs);
              final lockedWidth = constraints.maxWidth - unlockedWidth;

              return Row(
                children: <Widget>[
                  if (unlockedWidth > 0)
                    SizedBox(
                      width: unlockedWidth,
                      child: DecoratedBox(
                        decoration: BoxDecoration(color: context.colorScheme.primary),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  if (lockedWidth > 0)
                    SizedBox(
                      width: lockedWidth,
                      child: DecoratedBox(
                        decoration: BoxDecoration(color: context.colorScheme.outlineVariant),
                        child: const SizedBox.expand(),
                      ),
                    ),
                ],
              );
            },
          )
        : DecoratedBox(
            decoration: BoxDecoration(color: context.colorScheme.surfaceContainerHighest),
            child: const SizedBox.expand(),
          );

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
          child: SizedBox(height: 12, child: bar),
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
