import 'package:flutter/material.dart';
import 'package:pauza/src/core/localization/gen/app_localizations.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(appLocalizations.notFoundTitle)),
      body: Center(child: Text(appLocalizations.notFoundTitle)),
    );
  }
}
