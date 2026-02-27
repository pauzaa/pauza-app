import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/core/connectivity/domain/internet_required_guard.dart';
import 'package:pauza/src/features/profile/common/model/cached_user_profile.dart';
import 'package:pauza/src/features/profile/common/model/user_dto.dart';
import 'package:pauza/src/features/profile/data/user_profile_repository.dart';
import 'package:pauza/src/features/profile/edit/bloc/user_name_checker_bloc.dart';

void main() {
  group('UserNameCheckerBloc', () {
    test('offline emits offline and skips repository call', () async {
      final repository = _FakeUserProfileRepository();
      final guard = _FakeInternetRequiredGuard(canProceedResult: false);
      final bloc = UserNameCheckerBloc(
        userProfileRepository: repository,
        internetRequiredGuard: guard,
        debounceDuration: Duration.zero,
      );

      bloc.add(const UserNameCheckerStarted(username: 'john'));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(bloc.state, UsernameAvailability.offline);
      expect(repository.isUsernameAvailableCalls, 0);

      await bloc.close();
    });

    test('online emits available for available username', () async {
      final repository = _FakeUserProfileRepository();
      final guard = _FakeInternetRequiredGuard(canProceedResult: true);
      final bloc = UserNameCheckerBloc(
        userProfileRepository: repository,
        internetRequiredGuard: guard,
        debounceDuration: Duration.zero,
      );

      bloc.add(const UserNameCheckerStarted(username: 'john'));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(bloc.state, UsernameAvailability.available);
      expect(repository.isUsernameAvailableCalls, 1);

      await bloc.close();
    });
  });
}

final class _FakeUserProfileRepository implements UserProfileRepository {
  int isUsernameAvailableCalls = 0;

  @override
  Future<bool> isUsernameAvailable({required String username}) async {
    isUsernameAvailableCalls += 1;
    return true;
  }

  @override
  Future<CachedUserProfile?> readCachedProfile() async => null;

  @override
  Future<UserDto> fetchAndCacheProfile() {
    throw UnimplementedError();
  }

  @override
  Future<UserDto> updateProfile({
    required String name,
    required String username,
    String? profilePictureUrl,
    Uint8List? profilePictureBytes,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<String> uploadProfilePhoto({required String localFilePath}) {
    throw UnimplementedError();
  }

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
