import 'package:pauza/src/features/sync/common/model/sync_request_dto.dart';
import 'package:pauza/src/features/sync/data/sync_local_data_source.dart';
import 'package:pauza/src/features/sync/data/sync_remote_data_source.dart';

abstract interface class SyncRepository {
  Future<void> sync();
  Future<void> initialDownload();
}

final class SyncRepositoryImpl implements SyncRepository {
  const SyncRepositoryImpl({
    required SyncLocalDataSource localDataSource,
    required SyncRemoteDataSource remoteDataSource,
  }) : _localDataSource = localDataSource,
       _remoteDataSource = remoteDataSource;

  final SyncLocalDataSource _localDataSource;
  final SyncRemoteDataSource _remoteDataSource;

  @override
  Future<void> sync() async {
    final request = await _localDataSource.buildSyncRequest();
    final response = await _remoteDataSource.sync(request);
    await _localDataSource.applySyncResponse(response);
  }

  @override
  Future<void> initialDownload() async {
    await _localDataSource.clearAllSyncableTables();
    final request = SyncRequestDto.empty();
    final response = await _remoteDataSource.sync(request);
    await _localDataSource.applySyncResponse(response);
  }
}
