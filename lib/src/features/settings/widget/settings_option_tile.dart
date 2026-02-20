import 'package:flutter/material.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

final class SettingsOptionTile extends StatelessWidget {
  const SettingsOptionTile({required this.icon, required this.title, required this.trailing, super.key, this.onTap});

  final IconData icon;
  final String title;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = context.colorScheme.primary.withValues(alpha: 0.45);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(PauzaCornerRadius.large),
      side: BorderSide(color: borderColor),
    );

    return Material(
      color: context.colorScheme.surfaceContainerLowest,
      shape: shape,
      child: InkWell(
        onTap: onTap,
        customBorder: shape,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: PauzaSpacing.medium, vertical: PauzaSpacing.regular),
          child: Row(
            children: <Widget>[
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(PauzaCornerRadius.medium),
                  color: context.colorScheme.primary.withValues(alpha: 0.16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(PauzaSpacing.medium),
                  child: Icon(icon, color: context.colorScheme.primary),
                ),
              ),
              const SizedBox(width: PauzaSpacing.medium),
              Expanded(
                child: Text(title, style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}
