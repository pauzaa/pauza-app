import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class AiInsightSection extends StatelessWidget {
  const AiInsightSection({
    required this.title,
    required this.isLoading,
    required this.analysis,
    required this.error,
    required this.ctaLabel,
    required this.onRequest,
    super.key,
  });

  final String title;
  final bool isLoading;
  final String? analysis;
  final Object? error;
  final String ctaLabel;
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: theme.textTheme.titleMedium),
        const SizedBox(height: PauzaSpacing.small),
        if (isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: PauzaSpacing.large),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (error != null)
          _AiErrorCard(error: error!, onRetry: onRequest)
        else if (analysis != null)
          _AiAnalysisCard(analysis: analysis!)
        else
          FilledButton.tonal(onPressed: onRequest, child: Text(ctaLabel)),
      ],
    );
  }
}

class _AiAnalysisCard extends StatelessWidget {
  const _AiAnalysisCard({required this.analysis});

  final String analysis;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(PauzaSpacing.medium),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(PauzaSpacing.medium),
      ),
      child: MarkdownBody(
        data: analysis,
        selectable: true,
        styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(p: theme.textTheme.bodyMedium),
      ),
    );
  }
}

class _AiErrorCard extends StatelessWidget {
  const _AiErrorCard({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    final message = switch (error) {
      final Localizable error => error.localize(l10n),
      _ => l10n.aiErrorGeneric,
    };

    return Container(
      padding: const EdgeInsets.all(PauzaSpacing.medium),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(PauzaSpacing.medium),
      ),
      child: Column(
        children: [
          Text(message, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onErrorContainer)),
          const SizedBox(height: PauzaSpacing.small),
          TextButton(onPressed: onRetry, child: Text(l10n.aiRetry)),
        ],
      ),
    );
  }
}
