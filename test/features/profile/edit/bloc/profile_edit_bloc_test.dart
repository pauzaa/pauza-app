import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pauza/src/core/common/model/pauza_app_error.dart';
import 'package:pauza/src/features/profile/edit/bloc/profile_edit_bloc.dart';

import '../../../../helpers/helpers.dart';

void main() {
  late MockUserProfileRepository repository;
  late MockInternetRequiredGuard guard;

  setUpAll(registerTestFallbackValues);

  setUp(() {
    repository = MockUserProfileRepository();
    guard = MockInternetRequiredGuard();
  });

  group('ProfileEditBloc', () {
    blocTest<ProfileEditBloc, ProfileEditState>(
      'ProfileEditStarted calls fetchProfile with forceRemote: true',
      setUp: () {
        when(
          () => repository.fetchProfile(forceRemote: true),
        ).thenAnswer((_) async => makeUserDto(username: 'john', name: 'John'));
      },
      build: () => ProfileEditBloc(userProfileRepository: repository, internetRequiredGuard: guard),
      act: (bloc) => bloc.add(const ProfileEditStarted()),
      expect: () => <TypeMatcher<ProfileEditState>>[
        isA<ProfileEditLoading>(),
        isA<ProfileEditReady>(),
      ],
      verify: (_) {
        verify(() => repository.fetchProfile(forceRemote: true)).called(1);
      },
    );

    blocTest<ProfileEditBloc, ProfileEditState>(
      'offline save emits network failure and does not call repository update',
      setUp: () {
        when(
          () => repository.fetchProfile(forceRemote: any(named: 'forceRemote')),
        ).thenAnswer((_) async => makeUserDto(username: 'john', name: 'John'));
        when(() => guard.canProceed(forceRefresh: any(named: 'forceRefresh'))).thenAnswer((_) async => false);
      },
      build: () => ProfileEditBloc(userProfileRepository: repository, internetRequiredGuard: guard),
      act: (bloc) async {
        bloc.add(const ProfileEditStarted());
        await bloc.stream.firstWhere((s) => s is ProfileEditReady);
        bloc.add(
          const ProfileEditSaveRequested(
            name: 'John',
            username: 'john',
            profilePictureUrl: null,
            profilePictureBytes: null,
          ),
        );
      },
      expect: () => <TypeMatcher<ProfileEditState>>[
        isA<ProfileEditLoading>(),
        isA<ProfileEditReady>(),
        isA<ProfileEditSaving>(),
        isA<ProfileEditFailure>().having((s) => s.error, 'error', isA<PauzaInternetUnavailableError>()),
      ],
      verify: (_) {
        verify(() => repository.fetchProfile(forceRemote: any(named: 'forceRemote'))).called(1);
        verify(() => guard.canProceed(forceRefresh: any(named: 'forceRefresh'))).called(1);
        verifyNever(
          () => repository.updateProfile(
            name: any(named: 'name'),
            username: any(named: 'username'),
            profilePictureUrl: any(named: 'profilePictureUrl'),
            profilePictureBytes: any(named: 'profilePictureBytes'),
          ),
        );
      },
    );
  });
}
