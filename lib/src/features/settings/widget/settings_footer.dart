import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

final class SettingsFooter extends StatelessWidget {
  const SettingsFooter({
    required this.signOutLabel,
    required this.packageInfo,
    required this.versionLabel,
    required this.onSignOutTap,
    super.key,
  });

  final String signOutLabel;
  final PackageInfo packageInfo;
  final String Function(String version) versionLabel;
  final VoidCallback onSignOutTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: PauzaSpacing.regular,
      children: <Widget>[
        PauzaFilledButton(title: Text(signOutLabel), onPressed: onSignOutTap, icon: const Icon(Icons.logout_rounded)),
        Text(
          versionLabel(packageInfo.version),
          textAlign: TextAlign.center,
          style: context.textTheme.bodyLarge?.copyWith(color: context.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
