import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/core/localization/gen/app_localizations.g.dart';
import 'package:pauza/src/features/home/widget/home_current_mode_card.dart';
import 'package:pauza/src/features/modes/common/model/mode.dart';
import 'package:pauza/src/features/modes/common/model/mode_icon.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

void main() {
  testWidgets('renders selected mode icon token', (tester) async {
    final mode = Mode(
      id: 'mode-1',
      title: 'Focus',
      textOnScreen: 'Stay focused',
      description: null,
      allowedPausesCount: 1,
      icon: ModeIcon.fromToken('ms:v1:rocket_launch'),
      schedule: null,
      blockedAppIds: const ISet<AppIdentifier>.empty(),
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        theme: PauzaTheme.light,
        home: Scaffold(body: HomeCurrentModeCard(mode, onTap: () {})),
      ),
    );

    final icon = tester.widget<Icon>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Icon && widget.icon == mode.icon.icon,
      ),
    );

    expect(icon.icon, mode.icon.icon);
  });
}
