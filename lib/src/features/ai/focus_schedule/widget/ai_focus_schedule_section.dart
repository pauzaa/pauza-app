import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/ai/common/widget/ai_insight_section.dart';
import 'package:pauza/src/features/ai/focus_schedule/bloc/ai_focus_schedule_bloc.dart';

class AiFocusScheduleSection extends StatelessWidget {
  const AiFocusScheduleSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<AiFocusScheduleBloc, AiFocusScheduleState>(
      builder: (context, state) {
        return AiInsightSection(
          title: l10n.aiFocusSchedule,
          isLoading: state.isLoading,
          analysis: state.analysis,
          error: state.error,
          ctaLabel: l10n.aiFocusScheduleCta,
          onRequest: () => context.read<AiFocusScheduleBloc>().add(const AiFocusScheduleRequested()),
        );
      },
    );
  }
}
