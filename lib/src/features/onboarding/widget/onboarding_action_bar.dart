import 'package:flutter/material.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class OnboardingActionBar extends StatelessWidget {
  const OnboardingActionBar({
    required this.currentPage,
    required this.pageCount,
    required this.onComplete,
    required this.onNext,
    super.key,
  });

  final int currentPage;
  final int pageCount;
  final VoidCallback onComplete;
  final VoidCallback onNext;

  bool get _isFinalSlide => currentPage == pageCount - 1;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (_isFinalSlide) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SizedBox(
          width: double.infinity,
          child: PauzaFilledButton(title: Text(l10n.onboardingGetStarted), onPressed: onComplete),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          PauzaTextButton(title: Text(l10n.onboardingSkip), onPressed: onComplete),
          PauzaFilledButton(title: Text(l10n.onboardingNext), onPressed: onNext),
        ],
      ),
    );
  }
}
