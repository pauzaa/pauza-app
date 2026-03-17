import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/features/ai/addiction_check/widget/ai_addiction_check_section.dart';
import 'package:pauza/src/features/ai/focus_schedule/widget/ai_focus_schedule_section.dart';
import 'package:pauza/src/features/stats/blocking_stats/bloc/stats_blocking_bloc.dart';
import 'package:pauza/src/features/stats/blocking_stats/widget/stats_blocking_date_range_section.dart';
import 'package:pauza/src/features/stats/blocking_stats/widget/stats_blocking_empty_view.dart';
import 'package:pauza/src/features/stats/blocking_stats/widget/stats_blocking_error_view.dart';
import 'package:pauza/src/features/stats/blocking_stats/widget/stats_blocking_kpi_section.dart';
import 'package:pauza/src/features/stats/blocking_stats/widget/stats_blocking_mode_breakdown_section.dart';
import 'package:pauza/src/features/stats/blocking_stats/widget/stats_blocking_overview_section.dart';
import 'package:pauza/src/features/stats/blocking_stats/widget/stats_blocking_source_chart.dart';
import 'package:pauza/src/features/stats/blocking_stats/widget/stats_blocking_trend_chart.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class StatsBlockingTabContent extends StatelessWidget {
  const StatsBlockingTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StatsBlockingBloc, StatsBlockingState>(
      builder: (context, state) {
        return Column(
          children: [
            StatsBlockingDateRangeSection(
              selectedRange: state.window,
              maxDate: state.maxDate,
              isLoading: state.isLoading,
              onRangeChanged: (range) {
                context.read<StatsBlockingBloc>().add(StatsBlockingDateRangePicked(range));
              },
            ),
            if (state.isLoading && state.snapshot == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: PauzaSpacing.xLarge),
                child: CircularProgressIndicator(),
              )
            else if (state.hasError && state.snapshot == null)
              StatsBlockingErrorView(
                onRetry: () {
                  context.read<StatsBlockingBloc>().add(const StatsBlockingRefreshRequested());
                },
              )
            else if (state.snapshot != null && state.snapshot!.isEmpty)
              const StatsBlockingEmptyView()
            else if (state.snapshot != null) ...[
              const SizedBox(height: PauzaSpacing.large),
              StatsBlockingKpiSection(snapshot: state.snapshot!),
              const SizedBox(height: PauzaSpacing.large),
              StatsBlockingOverviewSection(snapshot: state.snapshot!),
              if (state.snapshot!.dailyTrend.isNotEmpty) ...[
                const SizedBox(height: PauzaSpacing.large),
                StatsBlockingTrendChart(dailyTrend: state.snapshot!.dailyTrend),
              ],
              if (state.modeBreakdown != null && !state.modeBreakdown!.isEmpty) ...[
                const SizedBox(height: PauzaSpacing.large),
                StatsBlockingModeBreakdownSection(modeBreakdown: state.modeBreakdown!),
              ],
              if (state.sourceBreakdown != null && !state.sourceBreakdown!.isEmpty) ...[
                const SizedBox(height: PauzaSpacing.large),
                StatsBlockingSourceChart(sourceBreakdown: state.sourceBreakdown!),
              ],
              const SizedBox(height: PauzaSpacing.large),
              const AiAddictionCheckSection(),
              const SizedBox(height: PauzaSpacing.large),
              const AiFocusScheduleSection(),
            ],
          ],
        );
      },
    );
  }
}
