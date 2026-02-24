import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/core/localization/gen/app_localizations.g.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

/// Pumps a [widget] wrapped in a [MaterialApp] with localization delegates,
/// the dark Pauza theme, and a [Scaffold] body.
///
/// Use [scrollable] (default `false`) to wrap the widget in a
/// [SingleChildScrollView] when it may overflow vertically.
Future<void> pumpStatsWidget(WidgetTester tester, Widget widget, {bool scrollable = false}) async {
  final body = scrollable ? SingleChildScrollView(child: widget) : widget;

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
      theme: PauzaTheme.dark,
      home: Scaffold(body: body),
    ),
  );
}
