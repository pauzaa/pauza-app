import 'package:pauza/src/core/api_client/api_client.dart';

abstract interface class EmergencyStopRemoteDataSource {
  Future<int> useEmergencyStop();

  Future<int> getRemainingStops();
}

final class EmergencyStopRemoteDataSourceImpl implements EmergencyStopRemoteDataSource {
  const EmergencyStopRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<int> useEmergencyStop() async {
    try {
      final response = await _apiClient.post('/emergency-stop');
      return response.data!['remaining_emergency_stops']! as int;
    } on ApiClientException catch (e) {
      throw ApiError.fromApiException(e);
    }
  }

  @override
  Future<int> getRemainingStops() async {
    try {
      final response = await _apiClient.get('/emergency-stops/remaining');
      return response.data!['remaining_emergency_stops']! as int;
    } on ApiClientException catch (e) {
      throw ApiError.fromApiException(e);
    }
  }
}
