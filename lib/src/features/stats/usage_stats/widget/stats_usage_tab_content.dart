import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/app/root_scope.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/ai/usage_analysis/bloc/ai_usage_analysis_bloc.dart';
import 'package:pauza/src/features/ai/usage_analysis/widget/ai_usage_analysis_section.dart';
import 'package:pauza/src/features/subscription/widget/premium_gate.dart';
import 'package:pauza/src/features/subscription/widget/premium_locked_card.dart';
import 'package:pauza/src/features/stats/usage_stats/bloc/stats_usage_bloc.dart';
import 'package:pauza/src/features/stats/usage_stats/widget/stats_usage_app_table.dart';
import 'package:pauza/src/features/stats/usage_stats/widget/stats_usage_category_chart.dart';
import 'package:pauza/src/features/stats/usage_stats/widget/stats_usage_date_range_section.dart';
import 'package:pauza/src/features/stats/usage_stats/widget/stats_usage_device_insights_section.dart';
import 'package:pauza/src/features/stats/usage_stats/widget/stats_usage_empty_view.dart';
import 'package:pauza/src/features/stats/usage_stats/widget/stats_usage_error_view.dart';
import 'package:pauza/src/features/stats/usage_stats/widget/stats_usage_kpi_row.dart';
import 'package:pauza/src/features/stats/usage_stats/widget/stats_usage_trend_chart.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class StatsUsageTabContent extends StatelessWidget {
  const StatsUsageTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StatsUsageBloc, StatsUsageState>(
      builder: (context, state) {
        return Column(
          children: [
            StatsUsageDateRangeSection(
              selectedRange: state.window,
              maxDate: state.maxDate,
              isLoading: state.isLoading,
              onRangeChanged: (range) {
                context.read<StatsUsageBloc>().add(StatsUsageDateRangePicked(range));
              },
            ),
            if (state.isLoading && !state.hasData)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: PauzaSpacing.xLarge),
                child: CircularProgressIndicator(),
              )
            else if (state.hasError && !state.hasData)
              StatsUsageErrorView(
                onRetry: () {
                  context.read<StatsUsageBloc>().add(const StatsUsageRefreshRequested());
                },
              )
            else if (state.hasData && state.snapshot!.isEmpty)
              const StatsUsageEmptyView()
            else if (state.hasData) ...[
              const SizedBox(height: PauzaSpacing.large),
              StatsUsageKpiRow(snapshot: state.snapshot!),
              if (state.dailyTrend != null && state.dailyTrend!.isNotEmpty) ...[
                const SizedBox(height: PauzaSpacing.large),
                StatsUsageTrendChart(dailyTrend: state.dailyTrend!),
              ],
              if (state.snapshot!.categoryBreakdown.isNotEmpty) ...[
                const SizedBox(height: PauzaSpacing.large),
                StatsUsageCategoryChart(categoryBreakdown: state.snapshot!.categoryBreakdown),
              ],
              const SizedBox(height: PauzaSpacing.large),
              StatsUsageAppTable(appUsageEntries: state.snapshot!.appUsageEntries),
              if (state.deviceEventSnapshot != null) ...[
                const SizedBox(height: PauzaSpacing.large),
                StatsUsageDeviceInsightsSection(snapshot: state.deviceEventSnapshot!),
              ],
              const SizedBox(height: PauzaSpacing.large),
              PremiumGate(
                lockedChild: PremiumLockedCard(title: context.l10n.aiUsageAnalysis),
                child: BlocProvider(
                  create: (context) {
                    final rootScope = RootScope.of(context);
                    return AiUsageAnalysisBloc(
                      aiRepository: rootScope.aiRepository,
                      usageRepository: rootScope.statsUsageRepository,
                    );
                  },
                  child: const AiUsageAnalysisSection(),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
