import 'package:pauza/src/core/localization/l10n.dart';

enum StatsSectionStatus implements Localizable {
  initial,
  loading,
  success,
  empty,
  failure;

  @override
  String localize(AppLocalizations localizations) {
    return switch (this) {
      StatsSectionStatus.initial => localizations.statsNoInsightData,
      StatsSectionStatus.loading => localizations.loadingLabel,
      StatsSectionStatus.success => localizations.statsNoInsightData,
      StatsSectionStatus.empty => localizations.statsNoInsightData,
      StatsSectionStatus.failure => localizations.statsInsightLoadFailed,
    };
  }
}
