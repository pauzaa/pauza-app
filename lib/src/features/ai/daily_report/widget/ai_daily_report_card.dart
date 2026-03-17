import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/ai/common/widget/ai_insight_section.dart';
import 'package:pauza/src/features/ai/daily_report/bloc/ai_daily_report_bloc.dart';

class AiDailyReportCard extends StatelessWidget {
  const AiDailyReportCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<AiDailyReportBloc, AiDailyReportState>(
      builder: (context, state) {
        return AiInsightSection(
          title: l10n.aiDailyReport,
          isLoading: state.isLoading,
          analysis: state.analysis,
          error: state.error,
          ctaLabel: l10n.aiDailyReportCta,
          onRequest: () => context.read<AiDailyReportBloc>().add(const AiDailyReportRequested()),
        );
      },
    );
  }
}
