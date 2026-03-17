import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/ai/common/widget/ai_insight_section.dart';
import 'package:pauza/src/features/ai/usage_analysis/bloc/ai_usage_analysis_bloc.dart';
import 'package:pauza/src/features/stats/usage_stats/bloc/stats_usage_bloc.dart';

class AiUsageAnalysisSection extends StatelessWidget {
  const AiUsageAnalysisSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<AiUsageAnalysisBloc, AiUsageAnalysisState>(
      builder: (context, state) {
        return AiInsightSection(
          title: l10n.aiUsageAnalysis,
          isLoading: state.isLoading,
          analysis: state.analysis,
          error: state.error,
          ctaLabel: l10n.aiUsageAnalysisCta,
          onRequest: () {
            final window = context.read<StatsUsageBloc>().state.window;
            context.read<AiUsageAnalysisBloc>().add(AiUsageAnalysisRequested(window: window));
          },
        );
      },
    );
  }
}
