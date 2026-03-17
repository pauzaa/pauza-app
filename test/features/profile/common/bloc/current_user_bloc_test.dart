import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pauza/src/features/auth/common/model/session.dart';
import 'package:pauza/src/features/profile/common/bloc/current_user_bloc.dart';
import 'package:pauza/src/features/profile/common/bloc/current_user_state.dart';
import 'package:pauza/src/features/profile/common/model/user_profile_failure.dart';

import '../../../../helpers/helpers.dart';

void main() {
  late MockAuthRepository authRepository;
  late MockUserProfileRepository profileRepository;
  late StreamController<Session> sessionController;

  final session = makeSession();
  final user = makeUserDto();

  setUp(() {
    authRepository = MockAuthRepository();
    profileRepository = MockUserProfileRepository();
    sessionController = StreamController<Session>.broadcast();

    when(() => authRepository.sessionStream).thenAnswer((_) => sessionController.stream);
    when(() => authRepository.currentSession).thenReturn(session);
    when(() => profileRepository.watchProfileChanges()).thenAnswer((_) => const Stream<Never>.empty());
  });

  tearDown(() async {
    await sessionController.close();
  });

  CurrentUserBloc buildBloc() =>
      CurrentUserBloc(authRepository: authRepository, userProfileRepository: profileRepository);

  group('CurrentUserBloc', () {
    test('initial state is unauthenticated', () {
      final bloc = buildBloc();
      expect(bloc.state, const CurrentUserState.unauthenticated());
      addTearDown(bloc.close);
    });

    test('signs out and transitions to unauthenticated on unauthorized profile refresh', () async {
      when(
        () => profileRepository.fetchProfile(forceRemote: any(named: 'forceRemote')),
      ).thenThrow(const UserProfileUnauthorizedError());
      when(() => authRepository.signOut()).thenAnswer((_) async {
        when(() => authRepository.currentSession).thenReturn(const Session.empty());
        sessionController.add(const Session.empty());
      });

      final bloc = buildBloc();
      addTearDown(bloc.close);

      bloc.add(CurrentUserSessionChanged(session: session));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      verify(() => authRepository.signOut()).called(1);
      expect(bloc.state, const CurrentUserState.unauthenticated());
    });

    blocTest<CurrentUserBloc, CurrentUserState>(
      'emits unavailable state with Object error for network failures',
      setUp: () {
        when(
          () => profileRepository.fetchProfile(forceRemote: any(named: 'forceRemote')),
        ).thenThrow(const UserProfileNetworkError());
      },
      build: buildBloc,
      act: (bloc) {
        bloc.add(const CurrentUserRefreshRequested(forceRemote: true));
      },
      wait: const Duration(milliseconds: 50),
      expect: () => <TypeMatcher<CurrentUserState>>[
        isA<CurrentUserState>()
            .having((s) => s.status, 'status', CurrentUserStatus.unavailable)
            .having((s) => s.error, 'error', isA<UserProfileNetworkError>()),
      ],
    );

    blocTest<CurrentUserBloc, CurrentUserState>(
      'emits error state with unknown Object error and message for unknown failures',
      setUp: () {
        when(
          () => profileRepository.fetchProfile(forceRemote: any(named: 'forceRemote')),
        ).thenThrow(UserProfileUnknownError(Exception('boom')));
      },
      build: buildBloc,
      act: (bloc) {
        bloc.add(const CurrentUserRefreshRequested(forceRemote: true));
      },
      wait: const Duration(milliseconds: 50),
      expect: () => <TypeMatcher<CurrentUserState>>[
        isA<CurrentUserState>()
            .having((s) => s.status, 'status', CurrentUserStatus.error)
            .having((s) => s.error, 'error', isA<UserProfileUnknownError>())
            .having((s) => s.message, 'message', contains('boom')),
      ],
    );

    blocTest<CurrentUserBloc, CurrentUserState>(
      'keeps available state when refresh fails with network error after successful load',
      setUp: () {
        var callCount = 0;
        when(() => profileRepository.fetchProfile(forceRemote: any(named: 'forceRemote'))).thenAnswer((_) async {
          callCount++;
          if (callCount == 1) return user;
          throw const UserProfileNetworkError();
        });
      },
      build: buildBloc,
      act: (bloc) async {
        bloc.add(CurrentUserSessionChanged(session: session));
        await Future<void>.delayed(const Duration(milliseconds: 50));
        bloc.add(const CurrentUserRefreshRequested(forceRemote: true));
      },
      wait: const Duration(milliseconds: 50),
      expect: () => <TypeMatcher<CurrentUserState>>[
        isA<CurrentUserState>().having((s) => s.status, 'status', CurrentUserStatus.loading),
        isA<CurrentUserState>()
            .having((s) => s.status, 'status', CurrentUserStatus.available)
            .having((s) => s.user, 'user', user),
      ],
    );
  });
}
