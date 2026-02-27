import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/core/common/model/pauza_app_error.dart';
import 'package:pauza/src/core/connectivity/domain/internet_required_guard.dart';
import 'package:pauza/src/features/profile/common/model/cached_user_profile.dart';
import 'package:pauza/src/features/profile/common/model/user_dto.dart';
import 'package:pauza/src/features/profile/data/user_profile_repository.dart';
import 'package:pauza/src/features/profile/edit/bloc/profile_edit_bloc.dart';

void main() {
  group('ProfileEditBloc', () {
    test('offline save emits network failure and does not call repository update', () async {
      final repository = _FakeUserProfileRepository();
      final guard = _FakeInternetRequiredGuard(canProceedResult: false);
      final bloc = ProfileEditBloc(userProfileRepository: repository, internetRequiredGuard: guard);

      bloc.add(const ProfileEditStarted());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      bloc.add(
        const ProfileEditSaveRequested(
          name: 'John',
          username: 'john',
          profilePictureUrl: null,
          profilePictureBytes: null,
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(bloc.state, isA<ProfileEditFailure>());
      final failure = bloc.state as ProfileEditFailure;
      expect(failure.error, PauzaAppError.internetUnavailable);
      expect(repository.updateProfileCalls, 0);

      await bloc.close();
    });
  });
}

final class _FakeUserProfileRepository implements UserProfileRepository {
  int updateProfileCalls = 0;

  @override
  Future<CachedUserProfile?> readCachedProfile() async {
    return CachedUserProfile(
      user: const UserDto(profilePicture: null, username: 'john', name: 'John'),
      cachedAtUtc: DateTime.utc(2026),
    );
  }

  @override
  Future<UserDto> fetchAndCacheProfile() async {
    return const UserDto(profilePicture: null, username: 'john', name: 'John');
  }

  @override
  Future<UserDto> updateProfile({
    required String name,
    required String username,
    String? profilePictureUrl,
    Uint8List? profilePictureBytes,
  }) async {
    updateProfileCalls += 1;
    return UserDto(profilePicture: profilePictureUrl, username: username, name: name);
  }

  @override
  Future<bool> isUsernameAvailable({required String username}) async => true;

  @override
  Future<String> uploadProfilePhoto({required String localFilePath}) async => '';

  @override
  Stream<UserDto> watchProfileChanges() => const Stream<UserDto>.empty();

  @override
  Future<void> clearCache() async {}
}

final class _FakeInternetRequiredGuard implements InternetRequiredGuard {
  _FakeInternetRequiredGuard({required this.canProceedResult});

  final bool canProceedResult;

  @override
  bool get isHealthy => canProceedResult;

  @override
  Future<bool> canProceed({bool forceRefresh = true}) async => canProceedResult;
}
