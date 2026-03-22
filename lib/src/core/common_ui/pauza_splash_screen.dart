import 'package:flutter/material.dart';
import 'package:pauza/src/core/common_ui/pauza_logo_icon.dart';

class PauzaSplashScreen extends StatelessWidget {
  const PauzaSplashScreen({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: PauzaLogoIcon()));
}
