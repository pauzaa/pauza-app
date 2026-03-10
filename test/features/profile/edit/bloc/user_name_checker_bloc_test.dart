import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pauza/src/features/profile/edit/bloc/user_name_checker_bloc.dart';

import '../../../../helpers/helpers.dart';

void main() {
  late MockUserProfileRepository repository;
  late MockInternetRequiredGuard guard;

  setUp(() {
    repository = MockUserProfileRepository();
    guard = MockInternetRequiredGuard();
  });

  group('UserNameCheckerBloc', () {
    blocTest<UserNameCheckerBloc, UsernameAvailability>(
      'offline emits offline and skips repository call',
      setUp: () {
        when(() => guard.canProceed(forceRefresh: any(named: 'forceRefresh'))).thenAnswer((_) async => false);
      },
      build: () => UserNameCheckerBloc(
        userProfileRepository: repository,
        internetRequiredGuard: guard,
        debounceDuration: Duration.zero,
      ),
      act: (bloc) => bloc.add(const UserNameCheckerStarted(username: 'john')),
      expect: () => <UsernameAvailability>[UsernameAvailability.offline],
      verify: (_) {
        verifyNever(() => repository.isUsernameAvailable(username: any(named: 'username')));
      },
    );

    blocTest<UserNameCheckerBloc, UsernameAvailability>(
      'online emits checking then available for available username',
      setUp: () {
        when(() => guard.canProceed(forceRefresh: any(named: 'forceRefresh'))).thenAnswer((_) async => true);
        when(() => repository.isUsernameAvailable(username: any(named: 'username'))).thenAnswer((_) async => true);
      },
      build: () => UserNameCheckerBloc(
        userProfileRepository: repository,
        internetRequiredGuard: guard,
        debounceDuration: Duration.zero,
      ),
      act: (bloc) => bloc.add(const UserNameCheckerStarted(username: 'john')),
      expect: () => <UsernameAvailability>[UsernameAvailability.checking, UsernameAvailability.available],
      verify: (_) {
        verify(() => repository.isUsernameAvailable(username: 'john')).called(1);
      },
    );

    blocTest<UserNameCheckerBloc, UsernameAvailability>(
      'online emits checking then taken for taken username',
      setUp: () {
        when(() => guard.canProceed(forceRefresh: any(named: 'forceRefresh'))).thenAnswer((_) async => true);
        when(() => repository.isUsernameAvailable(username: any(named: 'username'))).thenAnswer((_) async => false);
      },
      build: () => UserNameCheckerBloc(
        userProfileRepository: repository,
        internetRequiredGuard: guard,
        debounceDuration: Duration.zero,
      ),
      act: (bloc) => bloc.add(const UserNameCheckerStarted(username: 'taken_name')),
      expect: () => <UsernameAvailability>[UsernameAvailability.checking, UsernameAvailability.taken],
    );

    blocTest<UserNameCheckerBloc, UsernameAvailability>(
      'emits error for invalid username',
      build: () => UserNameCheckerBloc(
        userProfileRepository: repository,
        internetRequiredGuard: guard,
        debounceDuration: Duration.zero,
      ),
      act: (bloc) => bloc.add(const UserNameCheckerStarted(username: 'AB')),
      expect: () => <UsernameAvailability>[UsernameAvailability.error],
      verify: (_) {
        verifyNever(() => guard.canProceed(forceRefresh: any(named: 'forceRefresh')));
        verifyNever(() => repository.isUsernameAvailable(username: any(named: 'username')));
      },
    );

    blocTest<UserNameCheckerBloc, UsernameAvailability>(
      'emits error when repository throws',
      setUp: () {
        when(() => guard.canProceed(forceRefresh: any(named: 'forceRefresh'))).thenAnswer((_) async => true);
        when(() => repository.isUsernameAvailable(username: any(named: 'username'))).thenThrow(Exception('network'));
      },
      build: () => UserNameCheckerBloc(
        userProfileRepository: repository,
        internetRequiredGuard: guard,
        debounceDuration: Duration.zero,
      ),
      act: (bloc) => bloc.add(const UserNameCheckerStarted(username: 'john')),
      expect: () => <UsernameAvailability>[UsernameAvailability.checking, UsernameAvailability.error],
    );
  });
}
