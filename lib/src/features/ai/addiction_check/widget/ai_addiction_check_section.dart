import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/ai/addiction_check/bloc/ai_addiction_check_bloc.dart';
import 'package:pauza/src/features/ai/common/widget/ai_insight_section.dart';

class AiAddictionCheckSection extends StatelessWidget {
  const AiAddictionCheckSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<AiAddictionCheckBloc, AiAddictionCheckState>(
      builder: (context, state) {
        return AiInsightSection(
          title: l10n.aiAddictionCheck,
          isLoading: state.isLoading,
          analysis: state.analysis,
          error: state.error,
          ctaLabel: l10n.aiAddictionCheckCta,
          onRequest: () => context.read<AiAddictionCheckBloc>().add(const AiAddictionCheckRequested()),
        );
      },
    );
  }
}
