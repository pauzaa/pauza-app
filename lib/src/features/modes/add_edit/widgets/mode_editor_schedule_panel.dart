import 'package:flutter/material.dart';
import 'package:pauza/src/features/modes/add_edit/widgets/mode_editor_card.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

@immutable
class ModeEditorDayChipItem {
  const ModeEditorDayChipItem({
    required this.id,
    required this.label,
    required this.isSelected,
  });

  final String id;
  final String label;
  final bool isSelected;
}

final class ModeEditorSchedulePanel extends StatelessWidget {
  const ModeEditorSchedulePanel({
    required this.title,
    required this.enabled,
    required this.onToggle,
    required this.days,
    required this.onDayPressed,
    required this.startTitle,
    required this.endTitle,
    required this.startValue,
    required this.endValue,
    required this.onStartPressed,
    required this.onEndPressed,
    super.key,
    this.errorText,
  });

  final String title;
  final bool enabled;
  final ValueChanged<bool> onToggle;
  final List<ModeEditorDayChipItem> days;
  final ValueChanged<String> onDayPressed;
  final String startTitle;
  final String endTitle;
  final String startValue;
  final String endValue;
  final String? errorText;
  final VoidCallback onStartPressed;
  final VoidCallback onEndPressed;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: PauzaSpacing.small,
      children: <Widget>[
        ModeEditorCard(
          borderColor: hasError
              ? context.colorScheme.error.withValues(alpha: 0.8)
              : context.colorScheme.outlineVariant,
          child: Column(
            spacing: PauzaSpacing.medium,
            children: <Widget>[
              Row(
                spacing: PauzaSpacing.regular,
                children: <Widget>[
                  Icon(
                    Icons.calendar_today_outlined,
                    color: context.colorScheme.primary,
                    size: PauzaIconSizes.small,
                  ),
                  Expanded(
                    child: Text(
                      title,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  PauzaSwitch(value: enabled, onChanged: onToggle),
                ],
              ),
              if (enabled) ...<Widget>[
                Wrap(
                  spacing: PauzaSpacing.small,
                  runSpacing: PauzaSpacing.small,
                  children: days
                      .map(
                        (item) => _ModeEditorDayChip(
                          item: item,
                          onPressed: () => onDayPressed(item.id),
                        ),
                      )
                      .toList(growable: false),
                ),
                Row(
                  spacing: PauzaSpacing.medium,
                  children: <Widget>[
                    Expanded(
                      child: _ModeEditorTimeField(
                        title: startTitle,
                        value: startValue,
                        onPressed: onStartPressed,
                      ),
                    ),
                    Expanded(
                      child: _ModeEditorTimeField(
                        title: endTitle,
                        value: endValue,
                        onPressed: onEndPressed,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        if (hasError)
          Text(
            errorText!,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.error,
            ),
          ),
      ],
    );
  }
}

final class _ModeEditorDayChip extends StatelessWidget {
  const _ModeEditorDayChip({required this.item, required this.onPressed});

  final ModeEditorDayChipItem item;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(PauzaCornerRadius.full),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: item.isSelected
              ? context.colorScheme.primary
              : context.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(PauzaCornerRadius.full),
          border: Border.all(
            color: item.isSelected
                ? context.colorScheme.primary
                : context.colorScheme.outlineVariant,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: PauzaSpacing.medium,
            vertical: PauzaSpacing.small,
          ),
          child: Text(
            item.label,
            style: context.textTheme.labelLarge?.copyWith(
              color: item.isSelected
                  ? context.colorScheme.onPrimary
                  : context.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

final class _ModeEditorTimeField extends StatelessWidget {
  const _ModeEditorTimeField({
    required this.title,
    required this.value,
    required this.onPressed,
  });

  final String title;
  final String value;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(PauzaCornerRadius.medium),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(PauzaCornerRadius.medium),
          border: Border.all(color: context.colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: PauzaSpacing.medium,
            vertical: PauzaSpacing.regular,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: PauzaSpacing.small,
            children: <Widget>[
              Text(
                title.toUpperCase(),
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                value,
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
