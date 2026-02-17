import 'package:flutter/material.dart';
import 'package:helm/helm.dart';
import 'package:pauza/src/core/routing/pauza_routes.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static void show(BuildContext context) {
    HelmRouter.push(context, PauzaRoutes.settings);
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}