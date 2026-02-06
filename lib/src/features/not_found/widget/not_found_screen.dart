import 'package:flutter/material.dart';
import 'package:helm/helm.dart';
import 'package:pauza/src/core/localization/gen/app_localizations.dart';
import 'package:pauza/src/core/routing/pauza_routes.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  static void show(BuildContext context) {
    HelmRouter.push(context, PauzaRoutes.notFound);
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(appLocalizations.appName)),
      body: Center(child: Text(appLocalizations.notFoundTitle)),
    );
  }
}
