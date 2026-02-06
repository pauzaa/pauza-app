import 'package:flutter/material.dart';
import 'package:pauza_ui_kit/src/theme/pauza_theme.dart';

final class PauzaSwitch extends StatelessWidget {
  const PauzaSwitch({
    required this.value,
    required this.onChanged,
    super.key,
    this.withIcon = false,
    this.label,
    this.title,
    this.titleStyle,
  });

  final Widget? title;
  final TextStyle? titleStyle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool withIcon;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onChanged == null;

    final effectiveTitle = title ?? (label != null ? Text(label!) : null);

    return Row(
      children: <Widget>[
        if (effectiveTitle case final title?)
          Expanded(
            child: DefaultTextStyle.merge(
              style: titleStyle ?? context.textTheme.labelLarge,
              child: title,
            ),
          ),
        SizedBox(
          height: 32,
          child: Switch(
            value: value,
            onChanged: onChanged,
            thumbIcon: withIcon
                ? WidgetStateProperty.resolveWith<Icon?>((
                    Set<WidgetState> states,
                  ) {
                    if (states.contains(WidgetState.selected)) {
                      return const Icon(Icons.done);
                    }
                    return const Icon(Icons.close);
                  })
                : null,
            thumbColor: WidgetStateProperty.resolveWith<Color?>((
              Set<WidgetState> states,
            ) {
              if (states.contains(WidgetState.selected)) {
                return context.colorScheme.onPrimary;
              }
              if (states.contains(WidgetState.pressed)) {
                return context.colorScheme.onSurfaceVariant;
              }
              if (states.contains(WidgetState.disabled)) {
                return context.colorScheme.onSurface;
              }
              return context.colorScheme.outlineVariant;
            }),
            trackColor: WidgetStateProperty.resolveWith<Color?>((
              Set<WidgetState> states,
            ) {
              if (states.contains(WidgetState.selected)) {
                return isDisabled
                    ? context.colorScheme.onSurface.withValues(alpha: 0.12)
                    : context.colorScheme.primary;
              }
              if (states.contains(WidgetState.disabled)) {
                return context.colorScheme.surface;
              }
              return context.colorScheme.surfaceContainerHighest;
            }),
            trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((
              Set<WidgetState> states,
            ) {
              if (states.contains(WidgetState.selected)) {
                return isDisabled ? null : context.colorScheme.primary;
              }
              if (states.contains(WidgetState.disabled)) {
                return context.colorScheme.onSurface.withValues(alpha: 0.12);
              }
              return context.colorScheme.outlineVariant;
            }),
          ),
        ),
      ],
    );
  }
}
