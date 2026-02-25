import 'package:flutter/material.dart';
import 'package:pauza/src/core/common/extensions.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/stats/usage_stats/model/app_engagement_insight.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class StatsTopEngagementAppRow extends StatelessWidget {
  const StatsTopEngagementAppRow({required this.insight, super.key});

  final AppEngagementInsight insight;

  @override
  Widget build(BuildContext context) {
    final score = (insight.engagementScore * 100).round();
    final scoreLabel = context.l10n.statsPercentValue('$score%');
    final launchesPerHour = context.l10n.statsLaunchesPerHourValue(insight.launchesPerHour.toStringAsFixed(1));
    final averageSessionLabel = insight.averageSessionDuration.formatDurationLabel(context.l10n);

    return Semantics(
      label: context.l10n.statsEngagementRowSemantics(insight.appInfo.name, scoreLabel, launchesPerHour),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Text(
              insight.appInfo.name,
              style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: PauzaSpacing.medium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text('${context.l10n.statsEngagementScore}: $scoreLabel', style: context.textTheme.bodyMedium),
                Text('${context.l10n.statsLaunchIntensity}: $launchesPerHour', style: context.textTheme.bodyMedium),
                Text(
                  '${context.l10n.statsAvgSession}: $averageSessionLabel',
                  style: context.textTheme.bodyMedium,
                ),
                Text(
                  '${context.l10n.statsUsageTableLaunchesColumn}: ${insight.totalLaunchCount}',
                  style: context.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
