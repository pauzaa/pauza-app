import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/stats/usage_stats/model/app_engagement_insight.dart';
import 'package:pauza/src/features/stats/usage_stats/model/stats_section_status.dart';
import 'package:pauza/src/features/stats/usage_stats/widget/stats_card.dart';
import 'package:pauza/src/features/stats/usage_stats/widget/stats_section_header.dart';
import 'package:pauza/src/features/stats/usage_stats/widget/stats_top_engagement_app_row.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class StatsTopEngagementAppsCard extends StatelessWidget {
  const StatsTopEngagementAppsCard({required this.status, required this.apps, required this.onRetry, super.key});

  final StatsSectionStatus status;
  final IList<AppEngagementInsight> apps;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return StatsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          StatsSectionHeader(label: context.l10n.statsTopEngagementApps),
          const SizedBox(height: PauzaSpacing.medium),
          if (status == StatsSectionStatus.loading)
            const SizedBox(height: 120, child: Center(child: CircularProgressIndicator()))
          else if (status == StatsSectionStatus.failure)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(context.l10n.statsInsightLoadFailed, style: context.textTheme.bodyLarge),
                const SizedBox(height: PauzaSpacing.medium),
                PauzaFilledButton(
                  onPressed: onRetry,
                  size: PauzaButtonSize.small,
                  title: Text(context.l10n.retryButton),
                ),
              ],
            )
          else if (status == StatsSectionStatus.empty || status == StatsSectionStatus.initial)
            Text(context.l10n.statsNoInsightData, style: context.textTheme.bodyLarge)
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: apps.length,
              separatorBuilder: (context, index) {
                return const Divider(height: PauzaSpacing.large);
              },
              itemBuilder: (context, index) {
                return StatsTopEngagementAppRow(insight: apps[index]);
              },
            ),
        ],
      ),
    );
  }
}
