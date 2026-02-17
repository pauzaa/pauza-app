import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/core/localization/gen/app_localizations.g.dart';
import 'package:pauza/src/features/auth/widget/otp_code/otp_actions_section.dart';
import 'package:pauza/src/features/auth/widget/otp_code/otp_header_text.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

void main() {
  testWidgets('renders OTP title, description, and masked email', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildApp(child: const OtpHeaderText(email: 'user@example.com')),
    );

    expect(find.text('Verify Your Email'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is RichText &&
            widget.text.toPlainText().contains('u***@example.com'),
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'shows countdown and disables resend when remaining seconds > 0',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildApp(
          child: OtpActionsSection(
            countdownStream: Stream.value(55),
            initialRemainingSeconds: 55,
            onResendTap: () {},
          ),
        ),
      );

      expect(find.text("Didn't receive a code?"), findsOneWidget);
      expect(find.text('Available in 00:55'), findsOneWidget);

      final resendButton = tester.widget<PauzaTextButton>(
        find.byType(PauzaTextButton),
      );
      expect(resendButton.disabled, isTrue);
    },
  );

  testWidgets(
    'resend callback is triggered when countdown is zero',
    (WidgetTester tester) async {
      var resendTapCount = 0;

      await tester.pumpWidget(
        _buildApp(
          child: OtpActionsSection(
            countdownStream: Stream.value(0),
            initialRemainingSeconds: 0,
            onResendTap: () {
              resendTapCount += 1;
            },
          ),
        ),
      );

      await tester.tap(find.text('Resend Code'));
      await tester.pump();

      expect(resendTapCount, 1);
    },
  );

  testWidgets('resend button is enabled when countdown is zero', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildApp(
        child: OtpActionsSection(
          countdownStream: Stream.value(0),
          initialRemainingSeconds: 0,
          onResendTap: () {},
        ),
      ),
    );

    expect(find.text("Didn't receive a code?"), findsOneWidget);
    expect(find.text('Available in 00:00'), findsNothing);

    final resendButton = tester.widget<PauzaTextButton>(
      find.byType(PauzaTextButton),
    );

    expect(resendButton.disabled, isFalse);
  });

}

Widget _buildApp({required Widget child}) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: PauzaTheme.dark,
    home: Scaffold(body: child),
  );
}
