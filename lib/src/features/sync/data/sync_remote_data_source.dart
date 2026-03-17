import 'package:pauza/src/core/api_client/api_client.dart';
import 'package:pauza/src/features/sync/common/model/sync_error.dart';
import 'package:pauza/src/features/sync/common/model/sync_request_dto.dart';
import 'package:pauza/src/features/sync/common/model/sync_response_dto.dart';

abstract interface class SyncRemoteDataSource {
  Future<SyncResponseDto> sync(SyncRequestDto request);
}

final class SyncRemoteDataSourceImpl implements SyncRemoteDataSource {
  const SyncRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<SyncResponseDto> sync(SyncRequestDto request) async {
    try {
      final response = await _apiClient.post(
        '/sync',
        body: request.toJson(),
      );
      return SyncResponseDto.fromJson(response.data!);
    } on ApiClientException catch (e) {
      throw SyncError.fromApiException(e);
    }
  }
}
