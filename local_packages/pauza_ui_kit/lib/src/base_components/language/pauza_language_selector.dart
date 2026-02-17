import 'package:flutter/material.dart';
import 'package:pauza_ui_kit/src/foundations/spacing.dart';
import 'package:pauza_ui_kit/src/theme/pauza_theme.dart';

final class PauzaLanguageSelector extends StatelessWidget {
  const PauzaLanguageSelector({
    required this.currentLocale,
    required this.supportedLanguages,
    required this.onLocaleSelected,
    super.key,
  });

  final Locale currentLocale;
  final Map<Locale, String> supportedLanguages;
  final ValueChanged<Locale> onLocaleSelected;

  @override
  Widget build(BuildContext context) {
    final currentCode = currentLocale.languageCode.toUpperCase();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: context.colorScheme.outline),
      ),
      child: PopupMenuButton<Locale>(
        onSelected: onLocaleSelected,
        initialValue: currentLocale,
        offset: const Offset(0, 44),
        color: context.colorScheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        itemBuilder: (context) {
          return supportedLanguages.entries
              .map((entry) {
                final isSelected = _sameLocale(currentLocale, entry.key);

                return PopupMenuItem<Locale>(
                  value: entry.key,
                  child: Row(
                    spacing: PauzaSpacing.small,
                    children: <Widget>[
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.circle_outlined,
                        size: 18,
                        color: isSelected
                            ? context.colorScheme.primary
                            : context.colorScheme.onSurfaceVariant,
                      ),
                      Expanded(child: Text(entry.value)),
                    ],
                  ),
                );
              })
              .toList(growable: false);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: PauzaSpacing.medium,
            vertical: PauzaSpacing.small,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: PauzaSpacing.small,
            children: <Widget>[
              Icon(
                Icons.language,
                size: 20,
                color: context.colorScheme.onSurfaceVariant,
              ),
              Text(
                currentCode,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20,
                color: context.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _sameLocale(Locale lhs, Locale rhs) {
    return lhs.languageCode == rhs.languageCode &&
        lhs.countryCode == rhs.countryCode &&
        lhs.scriptCode == rhs.scriptCode;
  }
}
