import 'package:flutter/material.dart';
import 'package:pauza/src/core/localization/gen/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(appLocalizations.appName)),
      body: Center(child: Text(appLocalizations.homeTitle)),
    );
  }
}
