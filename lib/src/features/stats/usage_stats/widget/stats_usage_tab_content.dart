import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helm/helm.dart';
import 'package:pauza/src/core/common/pauza_platform.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/core/routing/pauza_routes.dart';
import 'package:pauza/src/features/stats/common/widget/stats_date_range_picker_card.dart';
import 'package:pauza/src/features/stats/usage_stats/bloc/stats_bloc.dart';
import 'package:pauza/src/features/stats/usage_stats/bloc/stats_event.dart';
import 'package:pauza/src/features/stats/usage_stats/bloc/stats_state.dart';
import 'package:pauza/src/features/stats/usage_stats/model/stats_section_status.dart';
import 'package:pauza/src/features/stats/usage_stats/widget/stats_device_activity_insights_card.dart';
import 'package:pauza/src/features/stats/usage_stats/widget/stats_hourly_heatmap_card.dart';
import 'package:pauza/src/features/stats/usage_stats/widget/stats_inline_fallback_card.dart';
import 'package:pauza/src/features/stats/usage_stats/widget/stats_ios_usage_report_card.dart';
import 'package:pauza/src/features/stats/usage_stats/widget/stats_section_state_content.dart';
import 'package:pauza/src/features/stats/usage_stats/widget/stats_top_engagement_apps_card.dart';
import 'package:pauza/src/features/stats/usage_stats/widget/stats_total_time_card.dart';
import 'package:pauza/src/features/stats/usage_stats/widget/stats_usage_apps_table_card.dart';
import 'package:pauza/src/features/stats/usage_stats/widget/stats_usage_trend_card.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class StatsUsageTabContent extends StatelessWidget {
  const StatsUsageTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      spacing: PauzaSpacing.large,
      children: <Widget>[
        BlocSelector<StatsBloc, StatsState, ({DateTimeRange dateTimeRange, DateTime maxDate})>(
          selector: (state) {
            return (dateTimeRange: state.window, maxDate: state.maxDate);
          },
          builder: (context, state) {
            return StatsDateRangePickerCard(
              selectedRange: state.dateTimeRange,
              maxDate: state.maxDate,
              onRangeChanged: (range) {
                context.read<StatsBloc>().add(StatsDateRangePicked(range));
              },
            );
          },
        ),
        if (kPauzaPlatform == PauzaPlatform.ios) ...{
          const StatsIosUsageReportCard(),
        } else ...{
          BlocBuilder<StatsBloc, StatsState>(
            builder: (context, state) {
              if (state.error != null) {
                if (state.error is PauzaMissingPermissionError) {
                  return StatsInlineFallbackCard(
                    title: l10n.statsPermissionRequiredTitle,
                    message: l10n.statsPermissionRequiredBody,
                    actionLabel: l10n.permissionOpenSettingsButton,
                    onActionPressed: () {
                      HelmRouter.push(context, PauzaRoutes.permissions);
                    },
                  );
                } else {
                  return StatsInlineFallbackCard(
                    title: l10n.errorTitle,
                    message: l10n.statsLoadFailed,
                    actionLabel: l10n.retryButton,
                    onActionPressed: () {
                      context.read<StatsBloc>().add(const StatsRefreshRequested());
                    },
                  );
                }
              }

              if (state.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.summary case final summary?) {
                return Column(
                  spacing: PauzaSpacing.large,
                  children: <Widget>[
                    StatsTotalTimeCard(summary: summary),
                    StatsUsageTrendCard(summary: summary),
                    StatsSectionStateContent(
                      status: state.deviceInsightsStatus,
                      successBuilder: (context) {
                        if (state.deviceInsights case final deviceInsights?) {
                          return StatsDeviceActivityInsightsCard(insights: deviceInsights);
                        }
                        return StatsInlineFallbackCard(
                          title: l10n.statsDeviceInsights,
                          message: l10n.statsNoInsightData,
                        );
                      },
                      emptyBuilder: (context) {
                        return StatsInlineFallbackCard(
                          title: l10n.statsDeviceInsights,
                          message: l10n.statsNoInsightData,
                        );
                      },
                      failureBuilder: (context, onRetry) {
                        return StatsInlineFallbackCard(
                          title: l10n.statsDeviceInsights,
                          message: StatsSectionStatus.failure.fallbackMessage(l10n)!,
                          actionLabel: l10n.retryButton,
                          onActionPressed: onRetry,
                        );
                      },
                      loadingBuilder: (context) {
                        return const SizedBox(height: 120, child: Center(child: CircularProgressIndicator()));
                      },
                      onRetry: () {
                        context.read<StatsBloc>().add(const StatsRefreshRequested());
                      },
                    ),
                    StatsHourlyHeatmapCard(
                      status: state.heatmapStatus,
                      heatmap: state.hourlyHeatmap,
                      onRetry: () {
                        context.read<StatsBloc>().add(const StatsRefreshRequested());
                      },
                    ),
                    StatsTopEngagementAppsCard(
                      status: state.topEngagementStatus,
                      apps: state.topEngagementApps,
                      onRetry: () {
                        context.read<StatsBloc>().add(const StatsRefreshRequested());
                      },
                    ),
                    StatsUsageAppsTableCard(usageStats: state.usageStats),
                  ],
                );
              } else {
                return StatsInlineFallbackCard(title: l10n.emptyStateMessage, message: l10n.statsNoUsageData);
              }
            },
          ),
        },
      ],
    );
  }
}
