import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pauza/src/core/common/model/pauza_app_error.dart';
import 'package:pauza/src/features/auth/bloc/auth_bloc.dart';
import 'package:pauza/src/features/auth/common/model/auth_failure.dart';
import 'package:pauza/src/features/auth/common/model/auth_result.dart';
import 'package:pauza/src/features/auth/common/model/session.dart';
import 'package:pauza/src/features/auth/data/auth_repository.dart';

import '../../../helpers/helpers.dart';

void main() {
  group('AuthBloc', () {
    late FakeAuthRepository repository;
    late MockInternetRequiredGuard internetRequiredGuard;

    setUp(() {
      repository = FakeAuthRepository();
      internetRequiredGuard = MockInternetRequiredGuard();
      when(
        () => internetRequiredGuard.canProceed(forceRefresh: any(named: 'forceRefresh')),
      ).thenAnswer((_) async => true);
      when(() => internetRequiredGuard.isHealthy).thenReturn(true);
    });

    tearDown(() {
      repository.dispose();
    });

    blocTest<AuthBloc, AuthState>(
      'initial state is AuthIdle',
      build: () => AuthBloc(authRepository: repository, internetRequiredGuard: internetRequiredGuard),
      expect: () => <AuthState>[],
      verify: (bloc) {
        expect(bloc.state, isA<AuthIdle>());
      },
    );

    group('AuthOtpRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits AuthOtpRequired on success',
        build: () => AuthBloc(authRepository: repository, internetRequiredGuard: internetRequiredGuard),
        act: (bloc) => bloc.add(const AuthOtpRequested(email: 'john@doe.com')),
        expect: () => <Matcher>[
          isA<AuthSubmitting>(),
          isA<AuthOtpRequired>().having((s) => s.email, 'email', 'john@doe.com'),
        ],
        verify: (_) {
          expect(repository.requestOtpCalls, 1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits AuthFlowFailure when offline',
        setUp: () {
          when(
            () => internetRequiredGuard.canProceed(forceRefresh: any(named: 'forceRefresh')),
          ).thenAnswer((_) async => false);
        },
        build: () => AuthBloc(authRepository: repository, internetRequiredGuard: internetRequiredGuard),
        act: (bloc) => bloc.add(const AuthOtpRequested(email: 'john@doe.com')),
        expect: () => <Matcher>[
          isA<AuthFlowFailure>().having((s) => s.error, 'error', const PauzaInternetUnavailableError()),
        ],
        verify: (_) {
          expect(repository.requestOtpCalls, 0);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits AuthFlowFailure when repository throws',
        build: () {
          repository.dispose();
          repository = FakeAuthRepository(requestOtpError: const AuthUnknownError(cause: 'server error'));
          return AuthBloc(authRepository: repository, internetRequiredGuard: internetRequiredGuard);
        },
        act: (bloc) => bloc.add(const AuthOtpRequested(email: 'john@doe.com')),
        expect: () => <Matcher>[
          isA<AuthSubmitting>(),
          isA<AuthFlowFailure>()
              .having((s) => s.error, 'error', isA<AuthUnknownError>())
              .having((s) => s.email, 'email', 'john@doe.com'),
        ],
      );

      test('duplicate request is ignored when state is already AuthSubmitting', () async {
        final requestCompleter = Completer<AuthOtpRequiredResult>();
        final completeRepository = _CompletableOtpRequestRepository(requestCompleter: requestCompleter);
        final bloc = AuthBloc(authRepository: completeRepository, internetRequiredGuard: internetRequiredGuard);
        final states = <AuthState>[];
        final sub = bloc.stream.listen(states.add);

        // First request moves to AuthSubmitting (stuck because completer not completed)
        bloc.add(const AuthOtpRequested(email: 'john@doe.com'));
        await bloc.stream.firstWhere((s) => s is AuthSubmitting);

        // Queue a duplicate while still submitting
        bloc.add(const AuthOtpRequested(email: 'john@doe.com'));

        // Complete the first request
        requestCompleter.complete(
          const AuthOtpRequiredResult(challengeId: 'otp-challenge', email: 'john@doe.com'),
        );
        await bloc.stream.firstWhere((s) => s is AuthOtpRequired);

        // Allow time for the duplicate to process (it should be silently dropped)
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        // Only one AuthSubmitting and one AuthOtpRequired — no second OTP request cycle
        expect(states.whereType<AuthSubmitting>().length, 1);
        expect(states.whereType<AuthOtpRequired>().length, 1);
        expect(completeRepository.requestOtpCalls, 1);

        await sub.cancel();
        await bloc.close();
        completeRepository.dispose();
      });

      test('duplicate request is ignored when state is already AuthOtpRequired', () async {
        final bloc = AuthBloc(authRepository: repository, internetRequiredGuard: internetRequiredGuard);
        final states = <AuthState>[];
        final sub = bloc.stream.listen(states.add);

        bloc.add(const AuthOtpRequested(email: 'john@doe.com'));
        await bloc.stream.firstWhere((s) => s is AuthOtpRequired);
        expect(repository.requestOtpCalls, 1);

        states.clear();

        // Send a second request while already in AuthOtpRequired
        bloc.add(const AuthOtpRequested(email: 'john@doe.com'));

        // Allow time for the event to be processed
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        // State should not change — still AuthOtpRequired, no additional repository calls
        expect(bloc.state, isA<AuthOtpRequired>());
        expect(states, isEmpty);
        expect(repository.requestOtpCalls, 1);

        await sub.cancel();
        await bloc.close();
      });
    });

    group('AuthOtpResendRequested', () {
      test('emits AuthResending then AuthOtpRequired with incremented resentCount on success', () async {
        final bloc = AuthBloc(authRepository: repository, internetRequiredGuard: internetRequiredGuard);
        final states = <AuthState>[];
        final sub = bloc.stream.listen(states.add);

        bloc.add(const AuthOtpRequested(email: 'john@doe.com'));
        await bloc.stream.firstWhere((s) => s is AuthOtpRequired);
        expect((bloc.state as AuthOtpRequired).resentCount, 0);

        states.clear();
        bloc.add(const AuthOtpResendRequested());
        await bloc.stream.firstWhere((s) => s is AuthOtpRequired && s.resentCount > 0);

        // AuthResending should appear as an intermediate state before AuthOtpRequired
        expect(states, containsAllInOrder(<Matcher>[isA<AuthResending>(), isA<AuthOtpRequired>()]));
        final resendingState = states.whereType<AuthResending>().single;
        expect(resendingState.email, 'john@doe.com');
        expect(resendingState.resentCount, 0);

        expect(bloc.state, isA<AuthOtpRequired>());
        final otpState = bloc.state as AuthOtpRequired;
        expect(otpState.email, 'john@doe.com');
        expect(otpState.resentCount, 1);
        expect(otpState.resent, isTrue);
        expect(repository.resendOtpCalls, 1);

        await sub.cancel();
        await bloc.close();
      });

      test('increments resentCount on consecutive resends', () async {
        final bloc = AuthBloc(authRepository: repository, internetRequiredGuard: internetRequiredGuard);

        bloc.add(const AuthOtpRequested(email: 'john@doe.com'));
        await bloc.stream.firstWhere((s) => s is AuthOtpRequired);

        bloc.add(const AuthOtpResendRequested());
        await bloc.stream.firstWhere((s) => s is AuthOtpRequired && s.resentCount == 1);
        expect((bloc.state as AuthOtpRequired).resentCount, 1);

        bloc.add(const AuthOtpResendRequested());
        await bloc.stream.firstWhere((s) => s is AuthOtpRequired && s.resentCount == 2);
        expect((bloc.state as AuthOtpRequired).resentCount, 2);

        expect(repository.resendOtpCalls, 2);

        await bloc.close();
      });

      test('emits AuthResending then AuthFlowFailure preserving resentCount when repository throws', () async {
        repository.dispose();
        repository = FakeAuthRepository(resendOtpError: const AuthOtpCooldownError());
        final bloc = AuthBloc(authRepository: repository, internetRequiredGuard: internetRequiredGuard);
        final states = <AuthState>[];
        final sub = bloc.stream.listen(states.add);

        bloc.add(const AuthOtpRequested(email: 'john@doe.com'));
        await bloc.stream.firstWhere((s) => s is AuthOtpRequired);

        states.clear();
        bloc.add(const AuthOtpResendRequested());
        await bloc.stream.firstWhere((s) => s is AuthFlowFailure);

        // AuthResending should appear before AuthFlowFailure
        expect(states, containsAllInOrder(<Matcher>[isA<AuthResending>(), isA<AuthFlowFailure>()]));

        expect(bloc.state, isA<AuthFlowFailure>());
        final failure = bloc.state as AuthFlowFailure;
        expect(failure.error, isA<AuthOtpCooldownError>());
        expect(failure.email, 'john@doe.com');
        expect(failure.resentCount, 0);

        await sub.cancel();
        await bloc.close();
      });

      test('emits AuthResending then AuthFlowFailure when offline and preserves resentCount', () async {
        final bloc = AuthBloc(authRepository: repository, internetRequiredGuard: internetRequiredGuard);
        final states = <AuthState>[];
        final sub = bloc.stream.listen(states.add);

        bloc.add(const AuthOtpRequested(email: 'john@doe.com'));
        await bloc.stream.firstWhere((s) => s is AuthOtpRequired);

        // Successful first resend
        bloc.add(const AuthOtpResendRequested());
        await bloc.stream.firstWhere((s) => s is AuthOtpRequired && s.resentCount == 1);
        expect((bloc.state as AuthOtpRequired).resentCount, 1);

        // Go offline, second resend should fail
        states.clear();
        when(
          () => internetRequiredGuard.canProceed(forceRefresh: any(named: 'forceRefresh')),
        ).thenAnswer((_) async => false);
        bloc.add(const AuthOtpResendRequested());
        await bloc.stream.firstWhere((s) => s is AuthFlowFailure);

        // AuthResending emitted before the offline failure
        expect(states, containsAllInOrder(<Matcher>[isA<AuthResending>(), isA<AuthFlowFailure>()]));
        final resendingState = states.whereType<AuthResending>().single;
        expect(resendingState.email, 'john@doe.com');
        expect(resendingState.resentCount, 1);

        expect(bloc.state, isA<AuthFlowFailure>());
        final failure = bloc.state as AuthFlowFailure;
        expect(failure.error, const PauzaInternetUnavailableError());
        expect(failure.email, 'john@doe.com');
        expect(failure.resentCount, 1);

        await sub.cancel();
        await bloc.close();
      });

      blocTest<AuthBloc, AuthState>(
        'is no-op when current state is AuthIdle',
        build: () => AuthBloc(authRepository: repository, internetRequiredGuard: internetRequiredGuard),
        act: (bloc) => bloc.add(const AuthOtpResendRequested()),
        expect: () => <AuthState>[],
        verify: (_) {
          expect(repository.resendOtpCalls, 0);
        },
      );

      test(
        'resend from AuthFlowFailure state emits AuthResending then AuthOtpRequired preserving previous resentCount',
        () async {
          repository.dispose();
          repository = FakeAuthRepository(resendOtpError: const AuthOtpCooldownError());
          final bloc = AuthBloc(authRepository: repository, internetRequiredGuard: internetRequiredGuard);
          final states = <AuthState>[];
          final sub = bloc.stream.listen(states.add);

          bloc.add(const AuthOtpRequested(email: 'john@doe.com'));
          await bloc.stream.firstWhere((s) => s is AuthOtpRequired);

          // First resend fails
          bloc.add(const AuthOtpResendRequested());
          await bloc.stream.firstWhere((s) => s is AuthFlowFailure);
          expect(bloc.state, isA<AuthFlowFailure>());
          expect((bloc.state as AuthFlowFailure).resentCount, 0);

          // Fix error and retry resend from failure state
          states.clear();
          repository.resendOtpError = null;
          bloc.add(const AuthOtpResendRequested());
          await bloc.stream.firstWhere((s) => s is AuthOtpRequired);

          // AuthResending should appear before the successful AuthOtpRequired
          expect(states, containsAllInOrder(<Matcher>[isA<AuthResending>(), isA<AuthOtpRequired>()]));

          expect(bloc.state, isA<AuthOtpRequired>());
          final otpState = bloc.state as AuthOtpRequired;
          expect(otpState.email, 'john@doe.com');
          expect(otpState.resentCount, 1);

          await sub.cancel();
          await bloc.close();
        },
      );
    });

    group('AuthOtpSubmitted', () {
      test('emits AuthFlowSuccess on valid OTP', () async {
        final bloc = AuthBloc(authRepository: repository, internetRequiredGuard: internetRequiredGuard);

        bloc.add(const AuthOtpRequested(email: 'john@doe.com'));
        await bloc.stream.firstWhere((s) => s is AuthOtpRequired);

        bloc.add(const AuthOtpSubmitted(otp: '111111'));
        await bloc.stream.firstWhere((s) => s is AuthFlowSuccess);

        expect(bloc.state, isA<AuthFlowSuccess>());
        expect((bloc.state as AuthFlowSuccess).email, 'john@doe.com');

        await bloc.close();
      });

      test('emits AuthFlowFailure with AuthInvalidOtpError on wrong code', () async {
        final bloc = AuthBloc(authRepository: repository, internetRequiredGuard: internetRequiredGuard);

        bloc.add(const AuthOtpRequested(email: 'john@doe.com'));
        await bloc.stream.firstWhere((s) => s is AuthOtpRequired);

        bloc.add(const AuthOtpSubmitted(otp: '000000'));
        await bloc.stream.firstWhere((s) => s is AuthFlowFailure);

        expect(bloc.state, isA<AuthFlowFailure>());
        final failure = bloc.state as AuthFlowFailure;
        expect(failure.error, const AuthInvalidOtpError());
        expect(failure.email, 'john@doe.com');

        await bloc.close();
      });

      blocTest<AuthBloc, AuthState>(
        'emits AuthOtpChallengeMissingError when submitted without prior request',
        build: () => AuthBloc(authRepository: repository, internetRequiredGuard: internetRequiredGuard),
        act: (bloc) => bloc.add(const AuthOtpSubmitted(otp: '111111')),
        expect: () => <Matcher>[
          isA<AuthFlowFailure>().having((s) => s.error, 'error', const AuthOtpChallengeMissingError()),
        ],
      );

      test('emits AuthFlowFailure when offline', () async {
        final bloc = AuthBloc(authRepository: repository, internetRequiredGuard: internetRequiredGuard);

        bloc.add(const AuthOtpRequested(email: 'john@doe.com'));
        await bloc.stream.firstWhere((s) => s is AuthOtpRequired);

        when(
          () => internetRequiredGuard.canProceed(forceRefresh: any(named: 'forceRefresh')),
        ).thenAnswer((_) async => false);
        bloc.add(const AuthOtpSubmitted(otp: '111111'));
        await bloc.stream.firstWhere((s) => s is AuthFlowFailure);

        expect(bloc.state, isA<AuthFlowFailure>());
        expect((bloc.state as AuthFlowFailure).error, const PauzaInternetUnavailableError());
        expect(repository.verifyOtpCalls, 0);

        await bloc.close();
      });

      test('can retry OTP submit after failure', () async {
        final bloc = AuthBloc(authRepository: repository, internetRequiredGuard: internetRequiredGuard);

        bloc.add(const AuthOtpRequested(email: 'john@doe.com'));
        await bloc.stream.firstWhere((s) => s is AuthOtpRequired);

        // First attempt – wrong OTP
        bloc.add(const AuthOtpSubmitted(otp: '000000'));
        await bloc.stream.firstWhere((s) => s is AuthFlowFailure);
        expect(bloc.state, isA<AuthFlowFailure>());

        // Second attempt – correct OTP from failure state
        bloc.add(const AuthOtpSubmitted(otp: '111111'));
        await bloc.stream.firstWhere((s) => s is AuthFlowSuccess);
        expect(bloc.state, isA<AuthFlowSuccess>());

        await bloc.close();
      });
    });

    group('AuthSignOutRequested', () {
      test('emits AuthIdle after sign out', () async {
        final bloc = AuthBloc(authRepository: repository, internetRequiredGuard: internetRequiredGuard);

        bloc.add(const AuthOtpRequested(email: 'john@doe.com'));
        await bloc.stream.firstWhere((s) => s is AuthOtpRequired);

        bloc.add(const AuthSignOutRequested());
        await bloc.stream.firstWhere((s) => s is AuthIdle);

        expect(bloc.state, isA<AuthIdle>());

        await bloc.close();
      });

      blocTest<AuthBloc, AuthState>(
        'emits AuthFlowFailure when sign out throws',
        build: () {
          repository.dispose();
          repository = FakeAuthRepository(signOutError: const AuthUnknownError(cause: 'sign-out failed'));
          return AuthBloc(authRepository: repository, internetRequiredGuard: internetRequiredGuard);
        },
        act: (bloc) => bloc.add(const AuthSignOutRequested()),
        expect: () => <Matcher>[
          isA<AuthSubmitting>(),
          isA<AuthFlowFailure>().having((s) => s.error, 'error', isA<AuthUnknownError>()),
        ],
      );
    });

    group('AuthFlowResetRequested', () {
      test('emits AuthResetting then AuthIdle and clears pending OTP challenge', () async {
        final bloc = AuthBloc(authRepository: repository, internetRequiredGuard: internetRequiredGuard);
        final states = <AuthState>[];
        final sub = bloc.stream.listen(states.add);

        bloc.add(const AuthOtpRequested(email: 'john@doe.com'));
        await bloc.stream.firstWhere((s) => s is AuthOtpRequired);

        states.clear();
        bloc.add(const AuthFlowResetRequested());
        await bloc.stream.firstWhere((s) => s is AuthIdle);

        // AuthResetting should appear as an intermediate state before AuthIdle
        expect(states, containsAllInOrder(<Matcher>[isA<AuthResetting>(), isA<AuthIdle>()]));

        expect(bloc.state, isA<AuthIdle>());
        expect(repository.clearPendingOtpChallengeCallCount, 1);

        await sub.cancel();
        await bloc.close();
      });

      test('emits AuthResetting then AuthFlowFailure when clearPendingOtpChallenge throws', () async {
        repository.dispose();
        repository = FakeAuthRepository(clearChallengeError: const AuthUnknownError(cause: 'clear failed'));
        final bloc = AuthBloc(authRepository: repository, internetRequiredGuard: internetRequiredGuard);
        final states = <AuthState>[];
        final sub = bloc.stream.listen(states.add);

        // First move out of AuthIdle (reset from AuthIdle is a no-op).
        bloc.add(const AuthOtpRequested(email: 'john@doe.com'));
        await bloc.stream.firstWhere((s) => s is AuthOtpRequired);

        states.clear();
        bloc.add(const AuthFlowResetRequested());
        await bloc.stream.firstWhere((s) => s is AuthFlowFailure);

        // AuthResetting should appear before the failure
        expect(states, containsAllInOrder(<Matcher>[isA<AuthResetting>(), isA<AuthFlowFailure>()]));

        expect(bloc.state, isA<AuthFlowFailure>());
        expect((bloc.state as AuthFlowFailure).error, isA<AuthUnknownError>());

        await sub.cancel();
        await bloc.close();
      });

      test('reset failure preserves email context so resend can still recover', () async {
        repository.dispose();
        repository = FakeAuthRepository(clearChallengeError: const AuthUnknownError(cause: 'clear failed'));
        final bloc = AuthBloc(authRepository: repository, internetRequiredGuard: internetRequiredGuard);
        final states = <AuthState>[];
        final sub = bloc.stream.listen(states.add);

        // Reach AuthOtpRequired
        bloc.add(const AuthOtpRequested(email: 'john@doe.com'));
        await bloc.stream.firstWhere((s) => s is AuthOtpRequired);

        // Reset fails — email should be preserved in the failure state
        bloc.add(const AuthFlowResetRequested());
        await bloc.stream.firstWhere((s) => s is AuthFlowFailure);
        final failure = bloc.state as AuthFlowFailure;
        expect(failure.email, 'john@doe.com');
        expect(failure.error, isA<AuthUnknownError>());

        // From this failure state, resend should still work since email is preserved
        states.clear();
        repository.clearChallengeError = null; // fix the error for resend
        bloc.add(const AuthOtpResendRequested());
        await bloc.stream.firstWhere((s) => s is AuthOtpRequired);

        expect(bloc.state, isA<AuthOtpRequired>());
        expect((bloc.state as AuthOtpRequired).email, 'john@doe.com');
        expect((bloc.state as AuthOtpRequired).resentCount, 1);
        expect(repository.resendOtpCalls, 1);

        await sub.cancel();
        await bloc.close();
      });

      blocTest<AuthBloc, AuthState>(
        'is no-op when current state is AuthIdle',
        build: () => AuthBloc(authRepository: repository, internetRequiredGuard: internetRequiredGuard),
        act: (bloc) => bloc.add(const AuthFlowResetRequested()),
        expect: () => <AuthState>[],
        verify: (_) {
          expect(repository.clearPendingOtpChallengeCallCount, 0);
        },
      );
    });

    group('sequential event processing', () {
      test('queued otp request then submit are processed in order', () async {
        final bloc = AuthBloc(authRepository: repository, internetRequiredGuard: internetRequiredGuard);
        final states = <AuthState>[];
        final sub = bloc.stream.listen(states.add);

        bloc.add(const AuthOtpRequested(email: 'john@doe.com'));
        bloc.add(const AuthOtpSubmitted(otp: '111111'));
        await bloc.stream.firstWhere((s) => s is AuthFlowSuccess);

        // Should see: AuthSubmitting -> AuthOtpRequired -> AuthSubmitting -> AuthFlowSuccess
        expect(
          states,
          containsAllInOrder(<Matcher>[
            isA<AuthSubmitting>(),
            isA<AuthOtpRequired>(),
            isA<AuthSubmitting>(),
            isA<AuthFlowSuccess>(),
          ]),
        );

        await sub.cancel();
        await bloc.close();
      });

      test('queued otp request then resend then submit are processed in order', () async {
        final bloc = AuthBloc(authRepository: repository, internetRequiredGuard: internetRequiredGuard);
        final states = <AuthState>[];
        final sub = bloc.stream.listen(states.add);

        bloc.add(const AuthOtpRequested(email: 'john@doe.com'));
        bloc.add(const AuthOtpResendRequested());
        bloc.add(const AuthOtpSubmitted(otp: '111111'));
        await bloc.stream.firstWhere((s) => s is AuthFlowSuccess);

        // Should see: AuthSubmitting -> AuthOtpRequired -> AuthResending -> AuthOtpRequired -> AuthSubmitting -> AuthFlowSuccess
        expect(
          states,
          containsAllInOrder(<Matcher>[
            isA<AuthSubmitting>(),
            isA<AuthOtpRequired>(),
            isA<AuthResending>(),
            isA<AuthOtpRequired>(),
            isA<AuthSubmitting>(),
            isA<AuthFlowSuccess>(),
          ]),
        );

        // resentCount should be 1 after the resend
        final resendState = states.whereType<AuthOtpRequired>().last;
        expect(resendState.resentCount, 1);

        await sub.cancel();
        await bloc.close();
      });

      test('reset failure preserves email so otp submit can still succeed', () async {
        repository.dispose();
        repository = FakeAuthRepository(clearChallengeError: const AuthUnknownError(cause: 'fail'));
        final bloc = AuthBloc(authRepository: repository, internetRequiredGuard: internetRequiredGuard);

        // First move out of AuthIdle (reset from AuthIdle is a no-op).
        bloc.add(const AuthOtpRequested(email: 'john@doe.com'));
        await bloc.stream.firstWhere((s) => s is AuthOtpRequired);

        // Reset request will fail — email context should be preserved
        bloc.add(const AuthFlowResetRequested());
        await bloc.stream.firstWhere((s) => s is AuthFlowFailure);
        expect(bloc.state, isA<AuthFlowFailure>());
        expect((bloc.state as AuthFlowFailure).email, 'john@doe.com');

        // OTP submit from a failure state with preserved email should succeed
        bloc.add(const AuthOtpSubmitted(otp: '111111'));
        await bloc.stream.firstWhere((s) => s is AuthFlowSuccess);

        expect(bloc.state, isA<AuthFlowSuccess>());
        expect((bloc.state as AuthFlowSuccess).email, 'john@doe.com');

        await bloc.close();
      });
    });

    group('submit queued during resend', () {
      test('submit queued while resending processes after resend completes', () async {
        final resendCompleter = Completer<AuthOtpRequiredResult>();
        final completeRepository = _CompletableAuthRepository(resendCompleter: resendCompleter);
        final bloc = AuthBloc(authRepository: completeRepository, internetRequiredGuard: internetRequiredGuard);
        final states = <AuthState>[];
        final sub = bloc.stream.listen(states.add);

        // Request OTP to reach AuthOtpRequired
        bloc.add(const AuthOtpRequested(email: 'john@doe.com'));
        await bloc.stream.firstWhere((s) => s is AuthOtpRequired);

        // Queue resend (will pause at AuthResending because completer hasn't completed)
        // and then immediately queue submit
        bloc.add(const AuthOtpResendRequested());
        bloc.add(const AuthOtpSubmitted(otp: '111111'));

        // Wait for the bloc to reach AuthResending
        await bloc.stream.firstWhere((s) => s is AuthResending);

        // Complete the resend so the submit can process
        resendCompleter.complete(
          const AuthOtpRequiredResult(challengeId: 'otp-challenge', email: 'john@doe.com'),
        );

        // The submit event processes after resend completes; since the bloc uses
        // sequential(), it sees AuthOtpRequired and proceeds normally to success.
        await bloc.stream.firstWhere((s) => s is AuthFlowSuccess);

        expect(bloc.state, isA<AuthFlowSuccess>());

        await sub.cancel();
        await bloc.close();
        completeRepository.dispose();
      });
    });
  });
}

final class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    Session? initialSession,
    this.requestOtpError,
    this.resendOtpError,
    this.signOutError,
    this.clearChallengeError,
  }) : _currentSession = initialSession ?? const Session.empty();

  final StreamController<Session> _controller = StreamController<Session>.broadcast();

  Session _currentSession;
  String? _pendingChallenge;
  int clearPendingOtpChallengeCallCount = 0;
  int requestOtpCalls = 0;
  int resendOtpCalls = 0;
  int verifyOtpCalls = 0;

  final Object? requestOtpError;
  Object? resendOtpError;
  final Object? signOutError;
  Object? clearChallengeError;

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
    requestOtpCalls += 1;
    if (requestOtpError != null) throw requestOtpError!;
    _pendingChallenge = 'otp-challenge';
    return AuthOtpRequiredResult(challengeId: 'otp-challenge', email: email);
  }

  @override
  Future<AuthOtpRequiredResult> resendOtp({required String email}) async {
    resendOtpCalls += 1;
    if (resendOtpError != null) throw resendOtpError!;
    _pendingChallenge = 'otp-challenge';
    return AuthOtpRequiredResult(challengeId: 'otp-challenge', email: email);
  }

  @override
  Future<AuthResult> verifyOtp({required String otp}) async {
    verifyOtpCalls += 1;
    if (_pendingChallenge == null) {
      throw const AuthOtpChallengeMissingError();
    }

    if (otp != '111111') {
      throw const AuthInvalidOtpError();
    }

    final session = makeSession();
    final user = makeUserDto();
    _currentSession = session;
    _controller.add(session);
    return AuthSuccess(session: session, user: user);
  }

  @override
  Future<void> signOut() async {
    if (signOutError != null) throw signOutError!;
    _currentSession = const Session.empty();
    _controller.add(_currentSession);
  }

  @override
  Future<void> clearPendingOtpChallenge() async {
    clearPendingOtpChallengeCallCount += 1;
    if (clearChallengeError != null) throw clearChallengeError!;
    _pendingChallenge = null;
  }

  @override
  Future<String?> refreshSession() async => null;

  @override
  void dispose() {
    _controller.close();
  }
}

/// An [AuthRepository] that allows controlling the completion of [resendOtp]
/// via an external [Completer], so that the bloc can be observed in the
/// intermediate [AuthResending] state.
final class _CompletableAuthRepository implements AuthRepository {
  _CompletableAuthRepository({required this.resendCompleter});

  final Completer<AuthOtpRequiredResult> resendCompleter;

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
    _pendingChallenge = 'otp-challenge';
    return AuthOtpRequiredResult(challengeId: 'otp-challenge', email: email);
  }

  @override
  Future<AuthOtpRequiredResult> resendOtp({required String email}) async {
    return resendCompleter.future;
  }

  @override
  Future<AuthResult> verifyOtp({required String otp}) async {
    if (_pendingChallenge == null) {
      throw const AuthOtpChallengeMissingError();
    }
    if (otp != '111111') {
      throw const AuthInvalidOtpError();
    }

    final session = makeSession();
    final user = makeUserDto();
    _currentSession = session;
    _controller.add(session);
    return AuthSuccess(session: session, user: user);
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
  Future<String?> refreshSession() async => null;

  @override
  void dispose() {
    _controller.close();
  }
}

/// An [AuthRepository] that allows controlling the completion of [requestOtp]
/// via an external [Completer], so that the bloc can be observed in the
/// intermediate [AuthSubmitting] state for duplicate-guard testing.
final class _CompletableOtpRequestRepository implements AuthRepository {
  _CompletableOtpRequestRepository({required this.requestCompleter});

  final Completer<AuthOtpRequiredResult> requestCompleter;

  final StreamController<Session> _controller = StreamController<Session>.broadcast();

  Session _currentSession = const Session.empty();
  String? _pendingChallenge;
  int requestOtpCalls = 0;

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
    requestOtpCalls += 1;
    _pendingChallenge = 'otp-challenge';
    return requestCompleter.future;
  }

  @override
  Future<AuthOtpRequiredResult> resendOtp({required String email}) async {
    _pendingChallenge = 'otp-challenge';
    return AuthOtpRequiredResult(challengeId: 'otp-challenge', email: email);
  }

  @override
  Future<AuthResult> verifyOtp({required String otp}) async {
    if (_pendingChallenge == null) {
      throw const AuthOtpChallengeMissingError();
    }
    if (otp != '111111') {
      throw const AuthInvalidOtpError();
    }

    final session = makeSession();
    final user = makeUserDto();
    _currentSession = session;
    _controller.add(session);
    return AuthSuccess(session: session, user: user);
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
  Future<String?> refreshSession() async => null;

  @override
  void dispose() {
    _controller.close();
  }
}
