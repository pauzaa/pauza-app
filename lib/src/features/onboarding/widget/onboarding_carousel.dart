import 'package:flutter/material.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/onboarding/widget/onboarding_action_bar.dart';
import 'package:pauza/src/features/onboarding/widget/onboarding_page_indicator.dart';
import 'package:pauza/src/features/onboarding/widget/onboarding_slide_page.dart';

class OnboardingCarousel extends StatefulWidget {
  const OnboardingCarousel({required this.onComplete, super.key});

  final VoidCallback onComplete;

  @override
  State<OnboardingCarousel> createState() => _OnboardingCarouselState();
}

class _OnboardingCarouselState extends State<OnboardingCarousel> {
  final _pageController = PageController();
  final _currentPage = ValueNotifier<int>(0);

  @override
  void dispose() {
    _pageController.dispose();
    _currentPage.dispose();
    super.dispose();
  }

  void _goToNext() {
    _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  List<({IconData icon, String title, String body})> _slides(BuildContext context) {
    final l10n = context.l10n;
    return [
      (icon: Icons.pause_circle_filled, title: l10n.onboardingSlide1Title, body: l10n.onboardingSlide1Body),
      (icon: Icons.tune, title: l10n.onboardingSlide2Title, body: l10n.onboardingSlide2Body),
      (icon: Icons.local_fire_department, title: l10n.onboardingSlide3Title, body: l10n.onboardingSlide3Body),
      (icon: Icons.group, title: l10n.onboardingSlide4Title, body: l10n.onboardingSlide4Body),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final slides = _slides(context);

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: slides.length,
              onPageChanged: (index) => _currentPage.value = index,
              itemBuilder: (context, index) {
                final slide = slides[index];
                return OnboardingSlidePage(icon: slide.icon, title: slide.title, body: slide.body);
              },
            ),
          ),
          ValueListenableBuilder<int>(
            valueListenable: _currentPage,
            builder: (context, page, _) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                OnboardingPageIndicator(count: slides.length, currentPage: page),
                const SizedBox(height: 32),
                OnboardingActionBar(
                  currentPage: page,
                  pageCount: slides.length,
                  onComplete: widget.onComplete,
                  onNext: _goToNext,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
