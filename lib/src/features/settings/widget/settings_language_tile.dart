import 'package:flutter/material.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';
import 'package:pauza/src/features/settings/widget/settings_option_tile.dart';

typedef LocaleChanged = Future<void> Function(Locale locale);

final class SettingsLanguageTile extends StatelessWidget {
  const SettingsLanguageTile({
    required this.title,
    required this.currentLocale,
    required this.supportedLanguages,
    required this.dialogTitle,
    required this.dialogCancelLabel,
    required this.onLocaleChanged,
    super.key,
  });

  final String title;
  final Locale currentLocale;
  final Map<Locale, String> supportedLanguages;
  final String dialogTitle;
  final String dialogCancelLabel;
  final LocaleChanged onLocaleChanged;

  @override
  Widget build(BuildContext context) {
    final currentLabel = supportedLanguages[currentLocale] ?? currentLocale.languageCode;

    return SettingsOptionTile(
      icon: Icons.language_rounded,
      title: title,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: PauzaSpacing.tiny,
        children: <Widget>[
          Text(currentLabel, style: context.textTheme.titleLarge?.copyWith(color: context.colorScheme.onSurfaceVariant)),
          Icon(Icons.chevron_right_rounded, color: context.colorScheme.primary),
        ],
      ),
      onTap: () async {
        final selected = await PauzaLanguagePickerDialog.show(
          context,
          currentLocale: currentLocale,
          supportedLanguages: supportedLanguages,
          title: dialogTitle,
          cancelLabel: dialogCancelLabel,
        );
        if (selected case final locale? when context.mounted && locale != currentLocale) {
          await onLocaleChanged(selected);
        }
      },
    );
  }
}
