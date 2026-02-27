import 'package:flutter/material.dart';
import 'package:pauza/src/core/common_ui/no_internet_state.dart';
import 'package:pauza/src/core/connectivity/domain/internet_health_gate.dart';
import 'package:pauza/src/core/localization/l10n.dart';

class InternetRequiredBody extends StatelessWidget {
  const InternetRequiredBody({
    required this.gate,
    required this.child,
    this.offlineTitle,
    this.offlineMessage,
    this.offlineRetryButtonLabel,
    super.key,
  });

  final InternetHealthGate gate;
  final Widget child;
  final String? offlineTitle;
  final String? offlineMessage;
  final String? offlineRetryButtonLabel;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: gate,
      builder: (context, _) {
        if (gate.isHealthy) {
          return child;
        }
        final title = offlineTitle;
        final message = offlineMessage;
        final retryLabel = offlineRetryButtonLabel;
        if (title != null && message != null && retryLabel != null) {
          return NoInternetState(
            title: title,
            message: message,
            retryLabel: retryLabel,
            onRetry: () => gate.refresh(force: true),
          );
        }
        final l10n = context.l10n;

        return NoInternetState(
          title: title ?? l10n.errorTitle,
          message: message ?? l10n.internetRequiredToast,
          retryLabel: retryLabel ?? l10n.retryButton,
          onRetry: () => gate.refresh(force: true),
        );
      },
    );
  }
}
