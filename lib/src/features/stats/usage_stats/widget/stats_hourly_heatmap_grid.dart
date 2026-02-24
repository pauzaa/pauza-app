import 'dart:math' as math;

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:pauza/src/core/common/extensions.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class StatsHourlyHeatmapGrid extends StatelessWidget {
  const StatsHourlyHeatmapGrid({required this.heatmap, super.key});

  final IMap<int, Duration> heatmap;

  @override
  Widget build(BuildContext context) {
    final maxDurationMs = math.max(
      1,
      heatmap.values.fold<int>(0, (maxValue, duration) => math.max(maxValue, duration.inMilliseconds)),
    );

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 24,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: PauzaSpacing.small,
        mainAxisSpacing: PauzaSpacing.small,
        childAspectRatio: 1.25,
      ),
      itemBuilder: (context, index) {
        final hour = index;
        final duration = heatmap[hour] ?? Duration.zero;
        final intensity = duration.inMilliseconds / maxDurationMs;
        final alpha = (0.12 + (0.88 * intensity)).clamp(0.12, 1.0);
        final hourLabel = hour.toString().padLeft(2, '0');

        return Semantics(
          label: context.l10n.statsHeatmapHourSemantics(hourLabel, duration.formatDurationLabel(context.l10n)),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: context.colorScheme.primary.withValues(alpha: alpha),
              borderRadius: BorderRadius.circular(PauzaCornerRadius.small),
              border: Border.all(color: context.colorScheme.outlineVariant.withValues(alpha: 0.6)),
            ),
            child: Center(
              child: Text(
                hourLabel,
                style: context.textTheme.labelMedium?.copyWith(
                  color: context.colorScheme.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
