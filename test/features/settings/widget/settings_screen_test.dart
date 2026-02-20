import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/settings/widget/settings_footer.dart';
import 'package:pauza/src/features/settings/widget/settings_notifications_tile.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

void main() {
  group('SettingsFooter', () {
    testWidgets('displays formatted version text', (tester) async {
      final packageInfo = PackageInfo(
        appName: 'Pauza',
        packageName: 'com.example.pauza',
        version: '1.2.3',
        buildNumber: '45',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: PauzaTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SettingsFooter(
              signOutLabel: 'Sign Out',
              packageInfo: packageInfo,
              versionLabel: (version) => 'v$version',
              onSignOutTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('v1.2.3'), findsOneWidget);
      expect(find.text('Sign Out'), findsOneWidget);
    });
  });

  group('SettingsNotificationsTile', () {
    testWidgets('switch toggles on tap', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: PauzaTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: SettingsNotificationsTile(title: 'Notifications'),
          ),
        ),
      );

      expect(find.text('Notifications'), findsOneWidget);

      final switchWidgetBefore = tester.widget<PauzaSwitch>(
        find.byType(PauzaSwitch),
      );
      expect(switchWidgetBefore.value, isFalse);

      await tester.tap(find.byType(SettingsNotificationsTile));
      await tester.pump();

      final switchWidgetAfter = tester.widget<PauzaSwitch>(
        find.byType(PauzaSwitch),
      );
      expect(switchWidgetAfter.value, isTrue);
    });
  });
}
