import 'package:appfuse/appfuse.dart';
import 'package:flutter/material.dart';
import 'package:pauza/src/app/pauza_app.dart';
import 'package:pauza/src/core/common/pauza_dependencies.dart';
import 'package:pauza/src/core/common_ui/pauza_splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    AppFuseScope(
      themes: PauzaApp.themes,
      supportedLanguages: PauzaApp.supportedLanguages,
      localizationsDelegates: PauzaApp.localizationsDelegates,
      init: PauzaDependencies(),
      placeholder: const PauzaSplashScreen(),
      app: const PauzaApp(),
    ),
  );
}
