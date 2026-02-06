import 'package:appfuse/appfuse.dart';
import 'package:flutter/material.dart';
import 'package:pauza/src/core/localization/gen/app_localizations.dart';
import 'package:pauza/src/core/routing/pauza_router.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class PauzaApp extends StatefulWidget {
  const PauzaApp({super.key});

  static final themes = <Brightness, ThemeData>{
    Brightness.light: PauzaTheme.light,
    Brightness.dark: PauzaTheme.dark,
  };

  static const localizationsDelegates = AppLocalizations.localizationsDelegates;

  static final supportedLanguages = <Locale, String>{
    const Locale('uz'): 'O\'zbek',
    const Locale('en'): 'English',
    const Locale('ru'): 'Русский',
  };

  @override
  State<PauzaApp> createState() => _PauzaAppState();
}

class _PauzaAppState extends State<PauzaApp> with RouterStateMixin<PauzaApp> {
  @override
  Widget build(BuildContext context) => MaterialApp.router(
    locale: context.watchFuseState.locale,
    supportedLocales: context.readFuseState.supportedLocales,
    localizationsDelegates: context.readFuseState.localizationsDelegates,
    themeMode: context.watchFuseState.themeMode,
    theme: context.readFuseState.lightTheme,
    darkTheme: context.readFuseState.darkTheme,
    routerConfig: router,
  );
}
