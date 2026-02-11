import 'package:flutter/widgets.dart';
import 'package:pauza/src/core/localization/gen/app_localizations.g.dart';

export 'gen/app_localizations.g.dart';

abstract interface class Localizable {
  String localize(AppLocalizations localizations);
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
