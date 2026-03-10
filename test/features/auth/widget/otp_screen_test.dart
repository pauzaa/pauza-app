import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/core/connectivity/domain/internet_required_guard.dart';
import 'package:pauza/src/core/localization/gen/app_localizations.g.dart';
import 'package:pauza/src/features/auth/bloc/auth_bloc.dart';
import 'package:pauza/src/features/auth/common/model/auth_failure.dart';
import 'package:pauza/src/features/auth/common/model/auth_result.dart';
import 'package:pauza/src/features/auth/common/model/session.dart';
import 'package:pauza/src/features/auth/data/auth_repository.dart';
import 'package:pauza/src/features/auth/widget/otp_code/otp_actions_section.dart';
import 'package:pauza/src/features/auth/widget/otp_code/otp_header_text.dart';
import 'package:pauza/src/features/auth/widget/otp_code/otp_screen_content.dart';
import 'package:pauza/src/features/profile/common/model/user_dto.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

void main() {
  testWidgets('renders OTP title, description, and masked email', (WidgetTester tester) async {
    await tester.pumpWidget(_buildApp(child: const OtpHeaderText(email: 'user@example.com')));

    expect(find.text('Verify Your Email'), findsOneWidget);
    expect(
      find.byWidgetPredicate((widget) => widget is RichText && widget.text.toPlainText().contains('u***@example.com')),
      findsOneWidget,
    );
  });

  testWidgets('shows countdown and disables resend when remaining seconds > 0', (WidgetTester tester) async {
    await tester.pumpWidget(
      _buildApp(
        child: OtpActionsSection(countdownStream: Stream.value(55), initialRemainingSeconds: 55, onResendTap: () {}),
      ),
    );

    expect(find.text("Didn't receive a code?"), findsOneWidget);
    expect(find.text('Available in 00:55'), findsOneWidget);

    final resendButton = tester.widget<PauzaTextButton>(find.byType(PauzaTextButton));
    expect(resendButton.disabled, isTrue);
  });

  testWidgets('resend callback is triggered when countdown is zero', (WidgetTester tester) async {
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
  });

  testWidgets('resend button is enabled when countdown is zero', (WidgetTester tester) async {
    await tester.pumpWidget(
      _buildApp(
        child: OtpActionsSection(countdownStream: Stream.value(0), initialRemainingSeconds: 0, onResendTap: () {}),
      ),
    );

    expect(find.text("Didn't receive a code?"), findsOneWidget);
    expect(find.text('Available in 00:00'), findsNothing);

    final resendButton = tester.widget<PauzaTextButton>(find.byType(PauzaTextButton));

    expect(resendButton.disabled, isFalse);
  });

  group('OtpActionsSection isBusy', () {
    testWidgets('disables resend button when isBusy is true and countdown is zero', (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildApp(
          child: OtpActionsSection(
            countdownStream: Stream.value(0),
            initialRemainingSeconds: 0,
            isBusy: true,
            onResendTap: () {},
          ),
        ),
      );

      final resendButton = tester.widget<PauzaTextButton>(find.byType(PauzaTextButton));
      expect(resendButton.disabled, isTrue);
    });

    testWidgets('enables resend button when isBusy is false (default) and countdown is zero', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _buildApp(
          child: OtpActionsSection(countdownStream: Stream.value(0), initialRemainingSeconds: 0, onResendTap: () {}),
        ),
      );

      final resendButton = tester.widget<PauzaTextButton>(find.byType(PauzaTextButton));
      expect(resendButton.disabled, isFalse);
    });

    testWidgets('disables resend button when both isBusy and countdown are active', (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildApp(
          child: OtpActionsSection(
            countdownStream: Stream.value(30),
            initialRemainingSeconds: 30,
            isBusy: true,
            onResendTap: () {},
          ),
        ),
      );

      final resendButton = tester.widget<PauzaTextButton>(find.byType(PauzaTextButton));
      expect(resendButton.disabled, isTrue);
    });

    testWidgets('resend tap does not invoke callback when isBusy is true', (WidgetTester tester) async {
      var tapCount = 0;

      await tester.pumpWidget(
        _buildApp(
          child: OtpActionsSection(
            countdownStream: Stream.value(0),
            initialRemainingSeconds: 0,
            isBusy: true,
            onResendTap: () {
              tapCount += 1;
            },
          ),
        ),
      );

      // Attempt to tap the resend button (it should be disabled)
      await tester.tap(find.text('Resend Code'));
      await tester.pump();

      expect(tapCount, 0);
    });
  });

  group('OtpScreenContent', () {
    testWidgets('back navigation dispatches reset and pops screen on success', (WidgetTester tester) async {
      final repository = _FakeAuthRepository();
      final internetRequiredGuard = _FakeInternetRequiredGuard();
      final bloc = AuthBloc(authRepository: repository, internetRequiredGuard: internetRequiredGuard);
      addTearDown(bloc.close);

      // Seed the bloc into AuthOtpRequired so the OTP screen is valid
      bloc.add(const AuthOtpRequested(email: 'john@doe.com'));
      await bloc.stream.firstWhere((s) => s is AuthOtpRequired);

      // Build a two-page navigation stack: home -> otp screen
      await tester.pumpWidget(
        _buildBlocApp(
          bloc: bloc,
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) => BlocProvider<AuthBloc>.value(value: bloc, child: const OtpScreenContent()),
                    ),
                  );
                },
                child: const Text('Go to OTP'),
              );
            },
          ),
        ),
      );

      // Navigate to the OTP screen
      await tester.tap(find.text('Go to OTP'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify OTP screen is visible
      expect(find.text('Verify Your Email'), findsOneWidget);

      // Simulate system back button
      final popScopeState = tester.state<NavigatorState>(find.byType(Navigator).last);
      popScopeState.maybePop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // The reset handler dispatches AuthFlowResetRequested which transitions
      // to AuthResetting -> AuthIdle, and the BlocListener pops the screen.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // OTP screen should be popped — we should be back on the home page
      expect(find.text('Go to OTP'), findsOneWidget);
      expect(find.text('Verify Your Email'), findsNothing);
    });

    testWidgets('pin code field is disabled while bloc is in AuthSubmitting state', (WidgetTester tester) async {
      final requestCompleter = Completer<AuthOtpRequiredResult>();
      final repository = _CompletableOtpRequestRepository(requestCompleter: requestCompleter);
      final internetRequiredGuard = _FakeInternetRequiredGuard();
      final bloc = AuthBloc(authRepository: repository, internetRequiredGuard: internetRequiredGuard);
      addTearDown(bloc.close);

      // Manually seed the bloc. Since requestOtp waits on completer, it stays in AuthSubmitting.
      bloc.add(const AuthOtpRequested(email: 'john@doe.com'));
      await bloc.stream.firstWhere((s) => s is AuthSubmitting);

      await tester.pumpWidget(_buildBlocApp(bloc: bloc, child: const OtpScreenContent()));
      await tester.pump();

      // The PauzaPinCodeField should be disabled during AuthSubmitting
      final pinField = tester.widget<PauzaPinCodeField>(find.byKey(const Key('otp_pin_code_field')));
      expect(pinField.enabled, isFalse);

      // Complete the request to clean up
      requestCompleter.complete(
        const AuthOtpRequiredResult(challengeId: AuthRepositoryImpl.otpChallengeId, email: 'john@doe.com'),
      );
      await tester.pump();
    });

    testWidgets('displays email from bloc state in header', (WidgetTester tester) async {
      final repository = _FakeAuthRepository();
      final internetRequiredGuard = _FakeInternetRequiredGuard();
      final bloc = AuthBloc(authRepository: repository, internetRequiredGuard: internetRequiredGuard);
      addTearDown(bloc.close);

      bloc.add(const AuthOtpRequested(email: 'alice@test.org'));
      await bloc.stream.firstWhere((s) => s is AuthOtpRequired);

      await tester.pumpWidget(_buildBlocApp(bloc: bloc, child: const OtpScreenContent()));
      await tester.pump();

      // The email should be masked as a***@test.org in the header
      expect(
        find.byWidgetPredicate((widget) => widget is RichText && widget.text.toPlainText().contains('a***@test.org')),
        findsOneWidget,
      );
    });
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

Widget _buildBlocApp({required AuthBloc bloc, required Widget child}) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: PauzaTheme.dark,
    home: BlocProvider<AuthBloc>.value(value: bloc, child: child),
  );
}

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

final class _FakeAuthRepository implements AuthRepository {
  final StreamController<Session> _controller = StreamController<Session>.broadcast();
  Session _currentSession = const Session.empty();
  String? _pendingChallenge;

  @override
  Session get currentSession => _currentSession;

  @override
  Stream<Session> get sessionStream => _controller.stream;

  @override
  Future<void> initialize() async {
    _controller.add(_currentSession);
  }

  @override
  Future<AuthOtpRequiredResult> requestOtp({required String email}) async {
    _pendingChallenge = AuthRepositoryImpl.otpChallengeId;
    return AuthOtpRequiredResult(challengeId: AuthRepositoryImpl.otpChallengeId, email: email);
  }

  @override
  Future<AuthOtpRequiredResult> resendOtp({required String email}) async {
    _pendingChallenge = AuthRepositoryImpl.otpChallengeId;
    return AuthOtpRequiredResult(challengeId: AuthRepositoryImpl.otpChallengeId, email: email);
  }

  @override
  Future<AuthResult> verifyOtp({required String otp}) async {
    if (_pendingChallenge == null) throw const AuthOtpChallengeMissingError();
    if (otp != AuthRepositoryImpl.validOtp) throw const AuthInvalidOtpError();

    const session = Session(accessToken: 'access', refreshToken: 'refresh');
    const user = UserDto(profilePicture: 'https://example.com/avatar/new.png', username: 'new', name: 'New');
    _currentSession = session;
    _controller.add(session);
    return const AuthSuccess(session: session, user: user);
  }

  @override
  Future<void> signOut() async {
    _currentSession = const Session.empty();
    _controller.add(_currentSession);
  }

  @override
  Future<void> clearPendingOtpChallenge() async {
    _pendingChallenge = null;
  }

  @override
  void dispose() {
    _controller.close();
  }
}

final class _FakeInternetRequiredGuard implements InternetRequiredGuard {
  @override
  bool get isHealthy => true;

  @override
  Future<bool> canProceed({bool forceRefresh = true}) async => true;
}

/// An [AuthRepository] that allows controlling the completion of [requestOtp]
/// via an external [Completer].
final class _CompletableOtpRequestRepository implements AuthRepository {
  _CompletableOtpRequestRepository({required this.requestCompleter});

  final Completer<AuthOtpRequiredResult> requestCompleter;
  final StreamController<Session> _controller = StreamController<Session>.broadcast();
  Session _currentSession = const Session.empty();
  String? _pendingChallenge;

  @override
  Session get currentSession => _currentSession;

  @override
  Stream<Session> get sessionStream => _controller.stream;

  @override
  Future<void> initialize() async {
    _controller.add(_currentSession);
  }

  @override
  Future<AuthOtpRequiredResult> requestOtp({required String email}) async {
    _pendingChallenge = AuthRepositoryImpl.otpChallengeId;
    return requestCompleter.future;
  }

  @override
  Future<AuthOtpRequiredResult> resendOtp({required String email}) async {
    _pendingChallenge = AuthRepositoryImpl.otpChallengeId;
    return AuthOtpRequiredResult(challengeId: AuthRepositoryImpl.otpChallengeId, email: email);
  }

  @override
  Future<AuthResult> verifyOtp({required String otp}) async {
    if (_pendingChallenge == null) throw const AuthOtpChallengeMissingError();
    if (otp != AuthRepositoryImpl.validOtp) throw const AuthInvalidOtpError();

    const session = Session(accessToken: 'access', refreshToken: 'refresh');
    const user = UserDto(profilePicture: 'https://example.com/avatar/new.png', username: 'new', name: 'New');
    _currentSession = session;
    _controller.add(session);
    return const AuthSuccess(session: session, user: user);
  }

  @override
  Future<void> signOut() async {
    _currentSession = const Session.empty();
    _controller.add(_currentSession);
  }

  @override
  Future<void> clearPendingOtpChallenge() async {
    _pendingChallenge = null;
  }

  @override
  void dispose() {
    _controller.close();
  }
}
