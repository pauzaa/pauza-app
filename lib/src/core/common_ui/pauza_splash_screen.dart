import 'package:flutter/material.dart';

class PauzaSplashScreen extends StatelessWidget {
  const PauzaSplashScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}
