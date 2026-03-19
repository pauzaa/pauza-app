import 'package:pauza/src/core/api_client/api_client.dart';

abstract interface class DevicesRemoteDataSource {
  Future<void> register({required String fcmToken, required String platform});

  Future<void> unregister({required String fcmToken});
}

final class DevicesRemoteDataSourceImpl implements DevicesRemoteDataSource {
  const DevicesRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<void> register({required String fcmToken, required String platform}) async {
    try {
      await _apiClient.post('/devices', body: <String, Object?>{'fcm_token': fcmToken, 'platform': platform});
    } on ApiClientException catch (e) {
      throw ApiError.fromApiException(e);
    }
  }

  @override
  Future<void> unregister({required String fcmToken}) async {
    try {
      await _apiClient.post('/devices/unregister', body: <String, Object?>{'fcm_token': fcmToken});
    } on ApiClientException catch (e) {
      throw ApiError.fromApiException(e);
    }
  }
}
