import 'package:flutter/material.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/modes/add_edit/widgets/mode_editor_card.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

final class ModeEditorMinimumDurationTile extends StatelessWidget {
  const ModeEditorMinimumDurationTile({
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.actionLabel,
    required this.onPickPressed,
    super.key,
    this.clearLabel,
    this.onClearPressed,
  });

  final String title;
  final String subtitle;
  final Duration? duration;
  final String actionLabel;
  final String? clearLabel;
  final VoidCallback onPickPressed;
  final VoidCallback? onClearPressed;

  String _formatMinimumDuration(BuildContext context, Duration? duration) {
    if (duration == null) {
      return context.l10n.modeMinimumDurationNotSet;
    }
    return context.l10n.modeMinimumDurationValueMinutes(duration.inMinutes);
  }

  @override
  Widget build(BuildContext context) {
    return ModeEditorCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: PauzaSpacing.medium,
        children: <Widget>[
          Row(
            spacing: PauzaSpacing.regular,
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
              Text(
                _formatMinimumDuration(context, duration),
                style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          Row(
            spacing: PauzaSpacing.small,
            children: <Widget>[
              if (onClearPressed != null && duration != null)
                Expanded(
                  child: PauzaTextButton(
                    size: PauzaButtonSize.small,
                    title: Text(clearLabel ?? context.l10n.modeMinimumDurationClearButton),
                    onPressed: onClearPressed!,
                  ),
                ),
              Expanded(
                child: PauzaOutlinedButton(
                  size: PauzaButtonSize.small,
                  title: Text(actionLabel),
                  onPressed: onPickPressed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
