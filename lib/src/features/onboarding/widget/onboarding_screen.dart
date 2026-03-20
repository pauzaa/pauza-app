import 'package:appfuse/appfuse.dart';
import 'package:flutter/material.dart';
import 'package:helm/helm.dart';
import 'package:pauza/src/core/routing/pauza_routes.dart';
import 'package:pauza/src/features/onboarding/widget/onboarding_carousel.dart';

const onboardingCompletedKey = 'onboarding_completed';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void _onComplete(BuildContext context) {
    context.fuse.setCustomSetting<bool>(onboardingCompletedKey, true);
    HelmRouter.push(context, PauzaRoutes.auth);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: OnboardingCarousel(onComplete: () => _onComplete(context)));
  }
}
