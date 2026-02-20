import 'package:appfuse/appfuse.dart';
import 'package:flutter/material.dart';
import 'package:helm/helm.dart';
import 'package:pauza/src/app/pauza_app.dart';
import 'package:pauza/src/app/root_scope.dart';
import 'package:pauza/src/core/common/extensions.dart';
import 'package:pauza/src/core/init/pauza_dependencies.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/core/routing/pauza_routes.dart';
import 'package:pauza/src/features/auth/bloc/auth_bloc.dart';
import 'package:pauza/src/features/nfc_chip_config/widget/nfc_chip_conf_screen.dart';
import 'package:pauza/src/features/settings/widget/settings_footer.dart';
import 'package:pauza/src/features/settings/widget/settings_language_tile.dart';
import 'package:pauza/src/features/settings/widget/settings_navigation_tile.dart';
import 'package:pauza/src/features/settings/widget/settings_notifications_tile.dart';
import 'package:pauza/src/features/settings/widget/settings_section_title.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static void show(BuildContext context) {
    HelmRouter.push(context, PauzaRoutes.settings);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final currentLocale = Localizations.localeOf(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: PauzaSpacing.medium),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: SettingsSectionTitle(title: l10n.settingsGeneralSectionTitle)),
            SliverToBoxAdapter(child: SettingsNotificationsTile(title: l10n.settingsNotifications)),
            SliverToBoxAdapter(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SettingsLanguageTile(
                  title: l10n.settingsLanguage,
                  currentLocale: currentLocale,
                  supportedLanguages: PauzaApp.supportedLanguages,
                  dialogTitle: l10n.settingsLanguagePickerTitle,
                  dialogCancelLabel: l10n.cancelButton,
                  onLocaleChanged: (locale) async => context.changeAppLocale(locale),
                ),
              ),
            ),
            SliverToBoxAdapter(child: SettingsSectionTitle(title: l10n.settingsSessionEndingConfSectionTitle)),
            SliverToBoxAdapter(
              child: SettingsNavigationTile(
                icon: Icons.nfc_rounded,
                title: l10n.settingsNfcChipConfiguring,
                onTap: () {
                  NfcChipConfScreen.show(context);
                },
              ),
            ),
            SliverToBoxAdapter(
              child: SettingsNavigationTile(
                icon: Icons.qr_code_scanner_rounded,
                title: l10n.settingsQrCodeConfiguring,
                onTap: () {
                  HelmRouter.push(context, PauzaRoutes.qrCodeConfig);
                },
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SettingsFooter(
                  signOutLabel: l10n.settingsSignOut,
                  packageInfo: PauzaDependencies.of(context).packageInfo,
                  versionLabel: l10n.settingsVersionLabel,
                  onSignOutTap: () {
                    RootScope.of(context).authBloc.add(const AuthSignOutRequested());
                  },
                ),
              ),
            ),
          ].interleaved(const SliverToBoxAdapter(child: SizedBox(height: PauzaSpacing.medium))).toList(),
        ),
      ),
    );
  }
}
