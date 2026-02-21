import 'package:flutter/material.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class NfcLinkedChipsEmptyState extends StatelessWidget {
  const NfcLinkedChipsEmptyState({required this.isLoading, super.key});

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(PauzaSpacing.large),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: PauzaSpacing.small,
          children: [
            Text(
              context.l10n.nfcChipConfigNoTagsTitle,
              style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(
              isLoading ? context.l10n.loadingLabel : context.l10n.nfcChipConfigNoTagsBody,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
