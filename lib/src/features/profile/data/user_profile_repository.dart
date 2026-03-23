import 'dart:async';
import 'dart:typed_data';

import 'package:pauza/src/features/profile/common/model/subscription_dto.dart';
import 'package:pauza/src/features/profile/common/model/user_dto.dart';
import 'package:pauza/src/features/profile/common/model/user_profile_failure.dart';
import 'package:pauza/src/features/profile/data/user_profile_remote_data_source.dart';

abstract interface class UserProfileRepository {
  Future<UserDto> fetchProfile({bool forceRemote});

  Future<UserDto> updateProfile({
    required String name,
    required String username,
    String? profilePictureUrl,
    Uint8List? profilePictureBytes,
  });

  Future<bool> isUsernameAvailable({required String username});

  Future<String> uploadProfilePhoto({required Uint8List bytes, required String filename});

  Future<bool> fetchNotificationPreferences();

  Future<bool> updateNotificationPreferences({required bool pushEnabled});

  Future<bool> fetchPrivacyPreferences();

  Future<bool> updatePrivacyPreferences({required bool leaderboardVisible});

  Future<void> requestAccountDeletion();

  Future<void> confirmAccountDeletion({required String otp});

  UserDto? get cachedUser;

  Stream<UserDto> watchProfileChanges();

  void applyOptimisticSubscription(SubscriptionDto? subscription);
}

final class UserProfileRepositoryImpl implements UserProfileRepository {
  UserProfileRepositoryImpl({
    required UserProfileRemoteDataSource remoteDataSource,
    Future<void> Function()? onAccountDeleted,
  }) : _remoteDataSource = remoteDataSource,
       _onAccountDeleted = onAccountDeleted;

  final UserProfileRemoteDataSource _remoteDataSource;
  final Future<void> Function()? _onAccountDeleted;
  final StreamController<UserDto> _profileChangesController = StreamController<UserDto>.broadcast();
  UserDto? _lastEmittedUser;

  @override
  UserDto? get cachedUser => _lastEmittedUser;

  @override
  Future<UserDto> fetchProfile({bool forceRemote = false}) async {
    try {
      final user = await _remoteDataSource.fetchMe(skipCache: forceRemote);
      _notifyIfChanged(user);
      return user;
    } on UserProfileError {
      rethrow;
    } on Object catch (e) {
      throw UserProfileUnknownError(e);
    }
  }

  @override
  Future<UserDto> updateProfile({
    required String name,
    required String username,
    String? profilePictureUrl,
    Uint8List? profilePictureBytes,
  }) async {
    try {
      if (profilePictureBytes != null) {
        await _remoteDataSource.uploadProfilePhoto(bytes: profilePictureBytes, filename: 'profile.jpg');
      }

      final updated = await _remoteDataSource.updateMe(name: name, username: username);
      _notifyIfChanged(updated);
      return updated;
    } on UserProfileError {
      rethrow;
    } on Object catch (e) {
      throw UserProfileUnknownError(e);
    }
  }

  @override
  Future<bool> isUsernameAvailable({required String username}) async {
    try {
      return _remoteDataSource.isUsernameAvailable(username: username);
    } on UserProfileError {
      rethrow;
    } on Object catch (e) {
      throw UserProfileUnknownError(e);
    }
  }

  @override
  Future<String> uploadProfilePhoto({required Uint8List bytes, required String filename}) async {
    try {
      return _remoteDataSource.uploadProfilePhoto(bytes: bytes, filename: filename);
    } on UserProfileError {
      rethrow;
    } on Object catch (e) {
      throw UserProfileUnknownError(e);
    }
  }

  @override
  Future<bool> fetchNotificationPreferences() async {
    try {
      return _remoteDataSource.fetchNotificationPreferences();
    } on UserProfileError {
      rethrow;
    } on Object catch (e) {
      throw UserProfileUnknownError(e);
    }
  }

  @override
  Future<bool> updateNotificationPreferences({required bool pushEnabled}) async {
    try {
      return await _remoteDataSource.updateNotificationPreferences(pushEnabled: pushEnabled);
    } on UserProfileError {
      rethrow;
    } on Object catch (e) {
      throw UserProfileUnknownError(e);
    }
  }

  @override
  Future<bool> fetchPrivacyPreferences() async {
    try {
      return _remoteDataSource.fetchPrivacyPreferences();
    } on UserProfileError {
      rethrow;
    } on Object catch (e) {
      throw UserProfileUnknownError(e);
    }
  }

  @override
  Future<bool> updatePrivacyPreferences({required bool leaderboardVisible}) async {
    try {
      return await _remoteDataSource.updatePrivacyPreferences(leaderboardVisible: leaderboardVisible);
    } on UserProfileError {
      rethrow;
    } on Object catch (e) {
      throw UserProfileUnknownError(e);
    }
  }

  @override
  Future<void> requestAccountDeletion() async {
    try {
      await _remoteDataSource.requestAccountDeletion();
    } on UserProfileError {
      rethrow;
    } on Object catch (e) {
      throw UserProfileUnknownError(e);
    }
  }

  @override
  Future<void> confirmAccountDeletion({required String otp}) async {
    try {
      await _remoteDataSource.confirmAccountDeletion(otp: otp);
      await _onAccountDeleted?.call();
    } on UserProfileError {
      rethrow;
    } on Object catch (e) {
      throw UserProfileUnknownError(e);
    }
  }

  @override
  Stream<UserDto> watchProfileChanges() {
    return _profileChangesController.stream;
  }

  @override
  void applyOptimisticSubscription(SubscriptionDto? subscription) {
    final current = _lastEmittedUser;
    if (current == null) return;
    // Cannot use copyWith here because it uses `??`, which prevents setting
    // subscription to null. Construct a new UserDto directly.
    _notifyIfChanged(
      UserDto(
        id: current.id,
        email: current.email,
        profilePicture: current.profilePicture,
        username: current.username,
        name: current.name,
        pushEnabled: current.pushEnabled,
        leaderboardVisible: current.leaderboardVisible,
        createdAt: current.createdAt,
        subscription: subscription,
      ),
    );
  }

  void _notifyIfChanged(UserDto user) {
    if (!_profileChangesController.isClosed && user != _lastEmittedUser) {
      _lastEmittedUser = user;
      _profileChangesController.add(user);
    }
  }
}
