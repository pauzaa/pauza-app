import 'package:flutter/material.dart';
import 'package:pauza/src/features/modes/add_edit/widgets/mode_editor_card.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

final class ModeEditorAllowedPausesTile extends StatelessWidget {
  const ModeEditorAllowedPausesTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onIncrement,
    required this.onDecrement,
    super.key,
    this.canIncrement = true,
    this.canDecrement = true,
  });

  final String title;
  final String subtitle;
  final int value;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final bool canIncrement;
  final bool canDecrement;

  @override
  Widget build(BuildContext context) {
    return ModeEditorCard(
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: PauzaSpacing.small,
              children: <Widget>[
                Text(title, style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                Text(
                  subtitle,
                  style: context.textTheme.bodyLarge?.copyWith(color: context.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(PauzaCornerRadius.large),
              border: Border.all(color: context.colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(PauzaSpacing.tiny),
              child: Row(
                spacing: PauzaSpacing.small,
                children: <Widget>[
                  PauzaIconButton.outlined(
                    onPressed: onDecrement,
                    disabled: !canDecrement,
                    icon: const Icon(Icons.remove),
                  ),
                  Text('$value', style: context.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
                  PauzaIconButton.filled(onPressed: onIncrement, disabled: !canIncrement, icon: const Icon(Icons.add)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
