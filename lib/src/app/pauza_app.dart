import 'package:appfuse/appfuse.dart';
import 'package:flutter/material.dart';
import 'package:pauza/src/core/common/pauza_dependencies.dart';
import 'package:pauza/src/core/common/root_scope.dart';
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
    const Locale('en'): 'English',
    const Locale('uz'): 'O\'zbek',
    const Locale('ru'): 'Русский',
  };

  @override
  State<PauzaApp> createState() => _PauzaAppState();
}

class _PauzaAppState extends State<PauzaApp> with RouterStateMixin<PauzaApp> {
  late final PauzaDependencies _dependencies;

  final Key builderKey = GlobalKey();

  @override
  void initState() {
    context.changeAppLocale(PauzaApp.supportedLanguages.keys.first);

    _dependencies = PauzaDependencies.of(context);

    super.initState();
  }

  @override
  void dispose() {
    _dependencies.permissionGate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      locale: context.watchFuseState.locale,
      supportedLocales: context.readFuseState.supportedLocales,
      localizationsDelegates: context.readFuseState.localizationsDelegates,
      themeMode: context.watchFuseState.themeMode,
      theme: context.readFuseState.lightTheme,
      darkTheme: context.readFuseState.darkTheme,
      routerConfig: router,
      builder: (context, child) {
        return MediaQuery(
          key: builderKey,
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
          child: RootScope(child: child ?? const SizedBox.shrink()),
        );
      },
    );
  }
}
