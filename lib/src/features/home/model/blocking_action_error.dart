import 'package:pauza/src/core/common/extensions.dart';
import 'package:pauza/src/core/localization/l10n.dart';

sealed class BlockingActionError implements Exception, Localizable {
  const BlockingActionError();
}

final class ActiveModeUnavailableError extends BlockingActionError {
  const ActiveModeUnavailableError();

  @override
  String localize(AppLocalizations localizations) {
    return localizations.homeActionBlockedModeUnavailable;
  }
}

final class PauseLimitReachedError extends BlockingActionError {
  const PauseLimitReachedError();

  @override
  String localize(AppLocalizations localizations) {
    return localizations.homePauseBlockedByLimit;
  }
}

final class MinimumDurationNotReachedError extends BlockingActionError {
  const MinimumDurationNotReachedError({required this.remaining});

  final Duration remaining;

  @override
  String localize(AppLocalizations localizations) {
    return localizations.homeActionBlockedByMinimumDuration(remaining.formatTimerHhMmSs());
  }
}
