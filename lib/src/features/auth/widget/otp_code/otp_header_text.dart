import 'package:flutter/material.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class OtpHeaderText extends StatelessWidget {
  const OtpHeaderText({required this.email, super.key});

  final String email;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final maskedEmail = _maskEmail(email);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: PauzaSpacing.large,
      children: <Widget>[
        Text(
          l10n.authOtpTitle,
          style: context.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        RichText(
          text: TextSpan(
            style: context.textTheme.headlineSmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
            children: <InlineSpan>[
              TextSpan(text: l10n.authOtpSubtitlePrefix),
              TextSpan(
                text: maskedEmail,
                style: context.textTheme.headlineSmall?.copyWith(
                  color: context.colorScheme.primary,
                ),
              ),
              TextSpan(text: l10n.authOtpSubtitleSuffix),
            ],
          ),
        ),
      ],
    );
  }

  String _maskEmail(String rawEmail) {
    final email = rawEmail.trim();
    final atIndex = email.indexOf('@');
    if (atIndex <= 0 || atIndex == email.length - 1) {
      return email;
    }

    final localPart = email.substring(0, atIndex);
    final domainPart = email.substring(atIndex + 1);
    final prefix = localPart.substring(0, 1);
    return '$prefix***@$domainPart';
  }
}
