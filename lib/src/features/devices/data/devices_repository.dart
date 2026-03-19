import 'dart:io' show Platform;

import 'package:pauza/src/core/api_client/api_client.dart';
import 'package:pauza/src/features/devices/data/devices_remote_data_source.dart';

abstract interface class DevicesRepository {
  Future<void> register({required String fcmToken});
  Future<void> unregister({required String fcmToken});
}

final class DevicesRepositoryImpl implements DevicesRepository {
  const DevicesRepositoryImpl({required DevicesRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final DevicesRemoteDataSource _remoteDataSource;

  @override
  Future<void> register({required String fcmToken}) async {
    try {
      await _remoteDataSource.register(fcmToken: fcmToken, platform: _currentPlatform);
    } on ApiError {
      rethrow;
    } on Object catch (e) {
      throw ApiUnknownError(e);
    }
  }

  @override
  Future<void> unregister({required String fcmToken}) async {
    try {
      await _remoteDataSource.unregister(fcmToken: fcmToken);
    } on ApiError {
      rethrow;
    } on Object catch (e) {
      throw ApiUnknownError(e);
    }
  }

  static String get _currentPlatform {
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    return 'unknown';
  }
}
