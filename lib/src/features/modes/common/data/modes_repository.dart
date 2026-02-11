

import 'package:pauza/src/core/common/pauza_platform.dart';
import 'package:pauza/src/core/local_database/local_database.dart';
import 'package:pauza/src/features/modes/common/model/mode.dart';
import 'package:uuid/uuid.dart';

abstract interface class ModesRepository {
  Future<List<Mode>> getModes();

  Future<Mode?> getMode(String modeId);

  Future<void> createMode(ModeUpsertDTO request);

  Future<void> updateMode({required String modeId, required ModeUpsertDTO request});

  Future<void> deleteMode(String modeId);
}

class ModesRepositoryImpl implements ModesRepository {
  const ModesRepositoryImpl({
    required LocalDatabase localDatabase,
    required this.platform,
    Uuid? uuid,
  }) : _localDatabase = localDatabase,
       _uuid = uuid ?? const Uuid();

  // ignore: unused_field
  final LocalDatabase _localDatabase;
  // ignore: unused_field
  final Uuid _uuid;
  final PauzaPlatform platform;

  @override
  Future<List<Mode>> getModes() async {
    throw UnimplementedError();
  }

  @override
  Future<Mode?> getMode(String modeId) async {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteMode(String modeId) async {
    throw UnimplementedError();
  }

  @override
  Future<void> createMode(ModeUpsertDTO request) async {
    throw UnimplementedError();
  }

  @override
  Future<void> updateMode({required String modeId, required ModeUpsertDTO request}) async {
    throw UnimplementedError();
  }
}
