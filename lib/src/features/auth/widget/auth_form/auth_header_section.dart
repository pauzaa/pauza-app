import 'package:flutter/material.dart';
import 'package:pauza/src/core/common_ui/pauza_logo_icon.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class AuthHeaderSection extends StatelessWidget {
  const AuthHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PauzaAppLogo(
      logoWidget: const PauzaLogoIcon(),
      appName: l10n.appName.toUpperCase(),
      tagline: l10n.authTagline.toUpperCase(),
    );
  }
}
