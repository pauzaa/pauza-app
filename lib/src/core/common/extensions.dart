import 'package:pauza/src/core/localization/l10n.dart';

extension IterableX<A> on Iterable<A> {
  /// Inserts [element] between elements of this [Iterable].
  Iterable<A> interleaved(A element) sync* {
    var index = 0;
    for (final current in this) {
      yield current;
      if (index++ != length - 1) yield element;
    }
  }
}

extension DurationX on Duration {
  String formatDurationLabel(AppLocalizations localizations) {
    final totalMinutes = inMinutes;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return localizations.homeDurationHoursMinutesLabel(hours, minutes);
  }
}
