import 'package:flutter/material.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

final class PauzaLanguagePickerDialog extends StatelessWidget {
  const PauzaLanguagePickerDialog({
    required this.currentLocale,
    required this.supportedLanguages,
    required this.title,
    required this.cancelLabel,
    super.key,
  });

  final Locale currentLocale;
  final Map<Locale, String> supportedLanguages;
  final String title;
  final String cancelLabel;

  static Future<Locale?> show(
    BuildContext context, {
    required Locale currentLocale,
    required Map<Locale, String> supportedLanguages,
    String title = 'Language',
    String cancelLabel = 'Cancel',
  }) {
    return showDialog<Locale>(
      context: context,
      builder: (context) {
        return PauzaLanguagePickerDialog(
          currentLocale: currentLocale,
          supportedLanguages: supportedLanguages,
          title: title,
          cancelLabel: cancelLabel,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      contentPadding: const EdgeInsets.only(top: 12),
      content: SizedBox(
        width: 320,
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          itemCount: supportedLanguages.entries.length,
          itemBuilder: (context, index) {
            final entry = supportedLanguages.entries.elementAt(index);
            final isSelected = currentLocale == entry.key;

            return ListTile(
              title: Text(entry.value),
              trailing: Icon(
                isSelected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: isSelected
                    ? context.colorScheme.primary
                    : context.colorScheme.onSurfaceVariant,
              ),
              onTap: () {
                Navigator.of(context).pop(entry.key);
              },
            );
          },
        ),
      ),
      actions: <Widget>[
        PauzaTextButton(
          onPressed: Navigator.of(context).pop,
          title: Text(cancelLabel),
        ),
      ],
    );
  }
}
