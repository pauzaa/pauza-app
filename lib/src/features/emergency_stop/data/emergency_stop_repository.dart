import 'package:pauza/src/features/emergency_stop/data/emergency_stop_remote_data_source.dart';

abstract interface class EmergencyStopRepository {
  Future<int> useEmergencyStop();

  Future<int> getRemainingStops();
}

final class EmergencyStopRepositoryImpl implements EmergencyStopRepository {
  const EmergencyStopRepositoryImpl({required EmergencyStopRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final EmergencyStopRemoteDataSource _remoteDataSource;

  @override
  Future<int> useEmergencyStop() => _remoteDataSource.useEmergencyStop();

  @override
  Future<int> getRemainingStops() => _remoteDataSource.getRemainingStops();
}
