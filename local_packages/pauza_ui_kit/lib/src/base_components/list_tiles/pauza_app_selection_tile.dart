import 'package:flutter/material.dart';
import 'package:pauza_ui_kit/src/foundations/sizes.dart';
import 'package:pauza_ui_kit/src/foundations/spacing.dart';
import 'package:pauza_ui_kit/src/theme/pauza_theme.dart';

final class PauzaAppSelectionTile extends StatelessWidget {
  const PauzaAppSelectionTile({
    required this.leading,
    required this.title,
    required this.trailing,
    required this.onTap,
    super.key,
  });

  final Widget leading;
  final String title;
  final Widget trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = context.colorScheme.outline.withValues(alpha: 0.55);

    return Material(
      color: context.colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PauzaCornerRadius.large),
        side: BorderSide(color: borderColor),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(PauzaCornerRadius.large),
        child: Padding(
          padding: const EdgeInsets.all(PauzaSpacing.medium),
          child: Row(
            spacing: PauzaSpacing.medium,
            children: <Widget>[
              leading,
              Expanded(
                child: Text(title, style: context.textTheme.titleLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}
