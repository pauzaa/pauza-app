import 'package:appfuse/appfuse.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pauza/firebase_options.dart';
import 'package:pauza/src/app/pauza_app.dart';
import 'package:pauza/src/core/init/pauza_dependencies.dart';
import 'package:pauza/src/core/common_ui/pauza_splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    AppFuseScope(
      themes: PauzaApp.themes,
      configs: PauzaApp.configs,
      supportedLanguages: PauzaApp.supportedLanguages,
      localizationsDelegates: PauzaApp.localizationsDelegates,
      init: PauzaDependencies(),
      placeholder: const PauzaSplashScreen(),
      app: const PauzaApp(),
    ),
  );
}
