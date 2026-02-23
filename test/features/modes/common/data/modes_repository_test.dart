import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/core/common/pauza_platform.dart';
import 'package:pauza/src/core/local_database/local_database.dart';
import 'package:pauza/src/features/modes/common/data/modes_repository.dart';
import 'package:pauza/src/features/modes/common/model/mode_ending_pausing_scenario.dart';
import 'package:pauza/src/features/modes/common/model/mode_icon.dart';
import 'package:pauza/src/features/modes/common/model/mode_upsert.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  group('ModesRepositoryImpl', () {
    test('createMode persists normalized icon token', () async {
      final database = _FakeLocalDatabase();
      final repository = ModesRepositoryImpl(localDatabase: database, platform: PauzaPlatform.android);

      final request = const ModeUpsertDTO.initialForDevice(hasNfcSupport: true).copyWith(
        title: 'Focus',
        textOnScreen: 'Stay focused',
        blockedAppIds: const ISet<AppIdentifier>.empty(),
        icon: ModeIcon.fromToken('invalid'),
      );

      await repository.createMode(request);

      final modesInsert = (database.fakeTransaction.batch() as _FakeBatch).operations.firstWhere(
        (operation) => operation.sql.contains('INSERT INTO modes'),
      );
      expect(modesInsert.arguments, contains(ModeIconCatalog.defaultToken));
      expect(modesInsert.arguments, contains(request.minimumDuration?.inMilliseconds));
      expect(modesInsert.arguments, contains(request.endingPausingScenario.dbValue));
    });

    test('updateMode persists normalized icon token', () async {
      final database = _FakeLocalDatabase();
      final repository = ModesRepositoryImpl(localDatabase: database, platform: PauzaPlatform.android);

      final request = const ModeUpsertDTO.initialForDevice(hasNfcSupport: true).copyWith(
        title: 'Focus',
        textOnScreen: 'Stay focused',
        blockedAppIds: const ISet<AppIdentifier>.empty(),
        icon: ModeIcon.fromToken('wrong'),
      );

      await repository.updateMode(modeId: 'mode-1', request: request);

      final update = (database.fakeTransaction.batch() as _FakeBatch).operations.firstWhere(
        (operation) => operation.sql.contains('UPDATE modes'),
      );
      expect(update.arguments, contains(ModeIconCatalog.defaultToken));
      expect(update.arguments, contains(request.minimumDuration?.inMilliseconds));
      expect(update.arguments, contains(request.endingPausingScenario.dbValue));
    });

    test('getModes maps invalid icon token to default token', () async {
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;
      final database = _FakeLocalDatabase()
        ..queryRows = <Map<String, Object?>>[
          <String, Object?>{
            'id': 'mode-1',
            'title': 'Focus',
            'text_on_screen': 'Stay focused',
            'description': null,
            'allowed_pauses_count': 1,
            'minimum_duration_ms': 900000,
            'ending_pausing_scenario': 'manual',
            'icon_token': 'invalid',
            'created_at': now,
            'updated_at': now,
            'schedule_days': null,
            'schedule_start_minute': null,
            'schedule_end_minute': null,
            'schedule_enabled': null,
            'blocked_apps': null,
          },
        ];
      final repository = ModesRepositoryImpl(localDatabase: database, platform: PauzaPlatform.android);

      final modes = await repository.getModes();

      expect(modes, hasLength(1));
      expect(modes.first.icon, ModeIconCatalog.defaultIcon);
      expect(modes.first.minimumDuration, const Duration(minutes: 15));
      expect(modes.first.endingPausingScenario, ModeEndingPausingScenario.manual);
    });

    test('watchModes emits on changes', () async {
      final database = _FakeLocalDatabase();
      final repository = ModesRepositoryImpl(localDatabase: database, platform: PauzaPlatform.android);

      final request = const ModeUpsertDTO.initialForDevice(
        hasNfcSupport: true,
      ).copyWith(title: 'Focus', textOnScreen: 'Stay focused', blockedAppIds: const ISet<AppIdentifier>.empty());

      final stream = repository.watchModes();

      // Expect 3 emissions: create, update, delete
      final expectation = expectLater(
        stream,
        emitsInOrder(<dynamic>[
          null, // After create
          null, // After update
          null, // After delete
        ]),
      );

      // Trigger operations
      await repository.createMode(request);
      await repository.updateMode(modeId: 'mode-1', request: request);
      await repository.deleteMode('mode-1');

      await expectation;
      repository.dispose();
    });
  });
}

final class _SqlOperation {
  const _SqlOperation({required this.sql, required this.arguments});

  final String sql;
  final List<Object?> arguments;
}

final class _FakeBatch implements Batch {
  final List<_SqlOperation> operations = <_SqlOperation>[];

  @override
  void rawInsert(String sql, [List<Object?>? arguments]) {
    operations.add(_SqlOperation(sql: sql, arguments: arguments ?? <Object?>[]));
  }

  @override
  void rawUpdate(String sql, [List<Object?>? arguments]) {
    operations.add(_SqlOperation(sql: sql, arguments: arguments ?? <Object?>[]));
  }

  @override
  void rawDelete(String sql, [List<Object?>? arguments]) {
    operations.add(_SqlOperation(sql: sql, arguments: arguments ?? <Object?>[]));
  }

  @override
  Future<List<Object?>> commit({bool? exclusive, bool? noResult, bool? continueOnError}) async => <Object?>[];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _FakeTransaction implements Transaction {
  _FakeTransaction();

  final _FakeBatch _batch = _FakeBatch();
  List<Map<String, Object?>> scheduleRows = const <Map<String, Object?>>[];
  List<Map<String, Object?>> blockedRows = const <Map<String, Object?>>[];

  @override
  Batch batch() => _batch;

  @override
  Future<List<Map<String, Object?>>> rawQuery(String sql, [List<Object?>? arguments]) async {
    if (sql.contains('FROM schedules')) {
      return scheduleRows;
    }
    if (sql.contains('FROM mode_blocked_apps')) {
      return blockedRows;
    }
    return const <Map<String, Object?>>[];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _FakeLocalDatabase implements LocalDatabase {
  List<Map<String, Object?>> queryRows = const <Map<String, Object?>>[];
  final _FakeTransaction fakeTransaction = _FakeTransaction();

  @override
  bool get isOpen => true;

  @override
  Future<void> close() async {}

  @override
  Future<void> open() async {}

  @override
  Future<List<Map<String, Object?>>> rawQuery(String sql, [List<Object?>? arguments]) async => queryRows;

  @override
  Future<int> rawInsert(String sql, [List<Object?>? arguments]) async => 0;

  @override
  Future<int> rawUpdate(String sql, [List<Object?>? arguments]) async => 0;

  @override
  Future<int> rawDelete(String sql, [List<Object?>? arguments]) async => 0;

  @override
  Future<T> read<T>(Future<T> Function(DatabaseExecutor database) action) async {
    throw UnimplementedError();
  }

  @override
  Future<T> write<T>(Future<T> Function(DatabaseExecutor database) action) async {
    throw UnimplementedError();
  }

  @override
  Future<T> transaction<T>(Future<T> Function(Transaction transactionFn) action) async {
    return action(fakeTransaction);
  }
}
