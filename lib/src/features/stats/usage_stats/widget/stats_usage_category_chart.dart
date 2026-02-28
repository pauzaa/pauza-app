import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pauza/src/core/common/extensions.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/stats/usage_stats/model/category_usage_bucket.dart';
import 'package:pauza/src/features/stats/common/widget/stats_chart_colors.dart';
import 'package:pauza/src/features/stats/usage_stats/widget/stats_usage_category_legend_item.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

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

    return Row(
      children: [
        SizedBox(
          width: 150,
          height: 150,
          child: PieChart(
            PieChartData(
              sections: [
                for (var i = 0; i < categoryBreakdown.length; i++)
                  PieChartSectionData(
                    value: categoryBreakdown[i].shareOfTotal * 100,
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
              for (var i = 0; i < categoryBreakdown.length; i++)
                StatsUsageCategoryLegendItem(
                  color: StatsChartColors.colorAt(i),
                  label: _resolveCategoryName(categoryBreakdown[i].category, l10n),
                  value: categoryBreakdown[i].totalDuration.formatDurationLabel(l10n),
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
