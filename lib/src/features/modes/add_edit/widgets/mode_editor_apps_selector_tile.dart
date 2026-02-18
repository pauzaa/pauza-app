import 'package:flutter/material.dart';
import 'package:pauza/src/features/modes/add_edit/widgets/mode_editor_card.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

final class ModeEditorAppsSelectorTile extends StatelessWidget {
  const ModeEditorAppsSelectorTile({
    required this.title,
    required this.subtitle,
    required this.selectedCountLabel,
    required this.onTap,
    super.key,
    this.errorText,
  });

  final String title;
  final String subtitle;
  final String selectedCountLabel;
  final String? errorText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;

    return Column(
      spacing: PauzaSpacing.small,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ModeEditorCard(
          borderColor: hasError ? context.colorScheme.error.withValues(alpha: 0.8) : null,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(PauzaCornerRadius.large),
            child: Row(
              spacing: PauzaSpacing.medium,
              children: <Widget>[
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: context.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(PauzaCornerRadius.medium),
                  ),
                  child: SizedBox(
                    width: PauzaFormSizes.xSmall,
                    height: PauzaFormSizes.xSmall,
                    child: Icon(Icons.apps, color: context.colorScheme.primary),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: PauzaSpacing.small,
                    children: <Widget>[
                      Text(title, style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                      Text(subtitle, style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: context.colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(PauzaCornerRadius.full),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: PauzaSpacing.medium, vertical: PauzaSpacing.small),
                    child: Text(
                      selectedCountLabel,
                      style: context.textTheme.labelLarge?.copyWith(color: context.colorScheme.primary, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: context.colorScheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
        if (hasError) Text(errorText!, style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.error)),
      ],
    );
  }
}
