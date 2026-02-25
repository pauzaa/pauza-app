import 'package:pauza/src/core/localization/l10n.dart';

enum StatsSectionStatus {
  initial,
  loading,
  success,
  empty,
  failure;

  String? fallbackMessage(AppLocalizations localizations) {
    return switch (this) {
      StatsSectionStatus.initial => localizations.statsNoInsightData,
      StatsSectionStatus.loading => localizations.loadingLabel,
      StatsSectionStatus.success => null,
      StatsSectionStatus.empty => localizations.statsNoInsightData,
      StatsSectionStatus.failure => localizations.statsInsightLoadFailed,
    };
  }
}
