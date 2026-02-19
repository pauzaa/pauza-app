import 'package:flutter/material.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class OtpActionsSection extends StatelessWidget {
  const OtpActionsSection({
    required this.countdownStream,
    required this.initialRemainingSeconds,
    required this.onResendTap,
    super.key,
  });

  final Stream<int> countdownStream;
  final int initialRemainingSeconds;
  final VoidCallback onResendTap;

  String _countdownLabel(BuildContext context, int remainingSeconds) {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return context.l10n.authOtpAvailableInLabel(
      minutes.toString().padLeft(2, '0'),
      seconds.toString().padLeft(2, '0'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 4,
      children: <Widget>[
        Text(
          l10n.authOtpDidNotReceiveCode,
          textAlign: TextAlign.center,
          style: context.textTheme.headlineSmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        StreamBuilder<int>(
          stream: countdownStream,
          initialData: initialRemainingSeconds,
          builder: (context, snapshot) {
            final remainingSeconds = snapshot.data ?? initialRemainingSeconds;

            return Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: <Widget>[
                PauzaTextButton(
                  onPressed: onResendTap,
                  disabled: remainingSeconds > 0,
                  title: Text(l10n.authOtpResendCode),
                ),
                if (remainingSeconds > 0) ...[
                  Text(
                    _countdownLabel(context, remainingSeconds),
                    textAlign: TextAlign.center,
                    style: context.textTheme.titleLarge?.copyWith(
                      color: context.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}
