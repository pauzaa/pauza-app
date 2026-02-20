import 'package:flutter/material.dart';
import 'package:pauza_ui_kit/src/foundations/spacing.dart';
import 'package:pauza_ui_kit/src/theme/pauza_theme.dart';

final class PauzaListTileCard extends StatelessWidget {
  const PauzaListTileCard({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.trailing,
    super.key,
    this.onTap,
    this.borderColor,
    this.enabled = true,
    this.borderWidth = 1,
  });

  final Widget leading;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;
  final Color? borderColor;
  final bool enabled;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: borderColor ?? context.colorScheme.outline, width: borderWidth),
    );

    return Material(
      color: context.colorScheme.surfaceContainerLow,
      shape: shape,
      child: InkWell(
        onTap: enabled ? onTap : null,
        customBorder: shape,
        child: Padding(
          padding: const EdgeInsets.all(PauzaSpacing.medium),
          child: Row(
            spacing: PauzaSpacing.medium,
            children: <Widget>[
              leading,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: PauzaSpacing.small,
                  children: <Widget>[
                    Text(title, style: context.textTheme.titleLarge),
                    Text(
                      subtitle,
                      style: context.textTheme.bodyLarge?.copyWith(color: context.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}
