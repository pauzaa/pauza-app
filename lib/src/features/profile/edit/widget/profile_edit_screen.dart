import 'package:flutter/material.dart';
import 'package:helm/helm.dart';
import 'package:pauza/src/core/routing/pauza_routes.dart';

class ProfileEditScreen extends StatelessWidget {
  const ProfileEditScreen({super.key});

  static void show(BuildContext context) {
    HelmRouter.push(context, PauzaRoutes.profileEdit);
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}