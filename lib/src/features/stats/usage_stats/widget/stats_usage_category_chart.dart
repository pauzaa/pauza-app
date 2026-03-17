import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pauza/src/core/common/extensions.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/stats/usage_stats/model/category_usage_bucket.dart';
import 'package:pauza/src/features/stats/common/widget/stats_chart_colors.dart';
import 'package:pauza/src/features/stats/usage_stats/widget/stats_usage_category_legend_item.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

const _maxDisplayed = 5;

class StatsUsageCategoryChart extends StatelessWidget {
  const StatsUsageCategoryChart({
    required this.categoryBreakdown,
    this.animationDuration = const Duration(milliseconds: 150),
    super.key,
  });

  final IList<CategoryUsageBucket> categoryBreakdown;
  final Duration animationDuration;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (categoryBreakdown.isEmpty) {
      return const SizedBox.shrink();
    }

    final IList<CategoryUsageBucket> displayed;
    if (categoryBreakdown.length <= _maxDisplayed) {
      displayed = categoryBreakdown;
    } else {
      final top = categoryBreakdown.take(_maxDisplayed).toIList();
      final rest = categoryBreakdown.skip(_maxDisplayed);
      final otherDuration = rest.fold(Duration.zero, (sum, b) => sum + b.totalDuration);
      final otherCount = rest.fold(0, (sum, b) => sum + b.appCount);
      final otherShare = rest.fold(0.0, (sum, b) => sum + b.shareOfTotal);

      // Merge with an existing null-category bucket in top 5, if any.
      final existingNullIndex = top.indexWhere((b) => b.category == null);
      if (existingNullIndex >= 0) {
        final existing = top[existingNullIndex];
        final merged = CategoryUsageBucket(
          category: null,
          totalDuration: existing.totalDuration + otherDuration,
          appCount: existing.appCount + otherCount,
          shareOfTotal: existing.shareOfTotal + otherShare,
        );
        displayed = top.replace(existingNullIndex, merged);
      } else {
        final otherBucket = CategoryUsageBucket(
          category: null,
          totalDuration: otherDuration,
          appCount: otherCount,
          shareOfTotal: otherShare,
        );
        displayed = top.add(otherBucket);
      }
    }

    return Row(
      children: [
        SizedBox(
          width: 150,
          height: 150,
          child: PieChart(
            PieChartData(
              sections: [
                for (var i = 0; i < displayed.length; i++)
                  PieChartSectionData(
                    value: displayed[i].shareOfTotal * 100,
                    color: StatsChartColors.colorAt(i),
                    radius: 60,
                    showTitle: false,
                  ),
              ],
              sectionsSpace: 2,
              centerSpaceRadius: 0,
            ),
            duration: animationDuration,
          ),
        ),
        const SizedBox(width: PauzaSpacing.medium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < displayed.length; i++)
                StatsUsageCategoryLegendItem(
                  color: StatsChartColors.colorAt(i),
                  label: _resolveCategoryName(displayed[i].category, l10n),
                  value: displayed[i].totalDuration.formatDurationLabel(l10n),
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _resolveCategoryName(String? category, AppLocalizations l10n) {
    if (category == null) return l10n.statsBucketOther;
    return category;
  }
}
