import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/core/common/pauza_platform.dart';
import 'package:pauza/src/core/local_database/local_database.dart';
import 'package:pauza/src/features/modes/common/data/modes_repository.dart';
import 'package:pauza/src/features/modes/common/model/mode_ending_pausing_scenario.dart';
import 'package:pauza/src/features/modes/common/model/mode_icon.dart';
import 'package:pauza/src/features/modes/common/model/mode_upsert.dart';
import 'package:pauza/src/features/modes/common/model/schedule.dart';
import 'package:pauza/src/features/modes/common/model/week_day.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  group('ModesRepositoryImpl', () {
    test('createMode persists normalized icon token and upserts plugin mode', () async {
      final database = _FakeLocalDatabase();
      final restrictions = _FakeAppRestrictionManager();
      final repository = ModesRepositoryImpl(
        localDatabase: database,
        platform: PauzaPlatform.android,
        restrictions: restrictions,
      );

      final request = const ModeUpsertDTO.initialForDevice(hasNfcSupport: true).copyWith(
        title: 'Focus',
        textOnScreen: 'Stay focused',
        blockedAppIds: const ISet<AppIdentifier>.empty(),
        icon: ModeIcon.fromToken('invalid'),
      );

      await repository.createMode(request);

      final operations = (database.fakeTransaction.batch() as _FakeBatch).operations;
      final modesInsert = operations.firstWhere((operation) => operation.sql.contains('INSERT INTO modes'));
      expect(modesInsert.arguments, contains(ModeIconCatalog.defaultToken));
      expect(modesInsert.arguments, contains(request.minimumDuration?.inMilliseconds));
      expect(modesInsert.arguments, contains(request.endingPausingScenario.dbValue));

      expect(restrictions.upsertedModes, hasLength(1));
      final upsertedMode = restrictions.upsertedModes.single;
      expect(upsertedMode.modeId, modesInsert.arguments.first);
      expect(upsertedMode.schedule, isNull);
    });

    test('createMode maps disabled schedule to plugin null schedule', () async {
      final database = _FakeLocalDatabase();
      final restrictions = _FakeAppRestrictionManager();
      final repository = ModesRepositoryImpl(
        localDatabase: database,
        platform: PauzaPlatform.android,
        restrictions: restrictions,
      );
      final request = const ModeUpsertDTO.initialForDevice(hasNfcSupport: true).copyWith(
        title: 'Mode',
        textOnScreen: 'Text',
        blockedAppIds: const ISet<AppIdentifier>.empty(),
        schedule: const Schedule(
          days: ISetConst(<WeekDay>{WeekDay.mon}),
          start: TimeOfDay(hour: 9, minute: 0),
          end: TimeOfDay(hour: 10, minute: 0),
          enabled: false,
        ),
      );

      await repository.createMode(request);

      expect(restrictions.upsertedModes.single.schedule, isNull);
    });

    test('createMode maps enabled schedule to plugin schedule', () async {
      final database = _FakeLocalDatabase();
      final restrictions = _FakeAppRestrictionManager();
      final repository = ModesRepositoryImpl(
        localDatabase: database,
        platform: PauzaPlatform.android,
        restrictions: restrictions,
      );
      final request = const ModeUpsertDTO.initialForDevice(hasNfcSupport: true).copyWith(
        title: 'Mode',
        textOnScreen: 'Text',
        blockedAppIds: const ISet<AppIdentifier>.empty(),
        schedule: const Schedule(
          days: ISetConst(<WeekDay>{WeekDay.mon, WeekDay.fri}),
          start: TimeOfDay(hour: 9, minute: 15),
          end: TimeOfDay(hour: 10, minute: 45),
          enabled: true,
        ),
      );

      await repository.createMode(request);

      final schedule = restrictions.upsertedModes.single.schedule;
      expect(schedule, isNotNull);
      expect(schedule!.daysOfWeekIso, <int>{1, 5});
      expect(schedule.startMinutes, 555);
      expect(schedule.endMinutes, 645);
    });

    test('createMode plugin failure prevents DB write', () async {
      final database = _FakeLocalDatabase();
      final restrictions = _FakeAppRestrictionManager()..throwOnUpsert = true;
      final repository = ModesRepositoryImpl(
        localDatabase: database,
        platform: PauzaPlatform.android,
        restrictions: restrictions,
      );

      final request = const ModeUpsertDTO.initialForDevice(
        hasNfcSupport: true,
      ).copyWith(title: 'Focus', textOnScreen: 'Stay focused', blockedAppIds: const ISet<AppIdentifier>.empty());

      await expectLater(repository.createMode(request), throwsA(isA<StateError>()));

      expect(database.transactionCalls, 0);
    });

    test('createMode DB failure compensates with plugin removeMode', () async {
      final database = _FakeLocalDatabase()..throwOnTransaction = true;
      final restrictions = _FakeAppRestrictionManager();
      final repository = ModesRepositoryImpl(
        localDatabase: database,
        platform: PauzaPlatform.android,
        restrictions: restrictions,
      );

      final request = const ModeUpsertDTO.initialForDevice(
        hasNfcSupport: true,
      ).copyWith(title: 'Focus', textOnScreen: 'Stay focused', blockedAppIds: const ISet<AppIdentifier>.empty());

      await expectLater(repository.createMode(request), throwsA(isA<StateError>()));

      expect(restrictions.upsertedModes, hasLength(1));
      expect(restrictions.removedModeIds, <String>[restrictions.upsertedModes.single.modeId]);
    });

    test('updateMode persists normalized icon token and upserts plugin mode', () async {
      final database = _FakeLocalDatabase()..queryRows = <Map<String, Object?>>[_modeRow()];
      final restrictions = _FakeAppRestrictionManager();
      final repository = ModesRepositoryImpl(
        localDatabase: database,
        platform: PauzaPlatform.android,
        restrictions: restrictions,
      );

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
      expect(restrictions.upsertedModes.first.modeId, 'mode-1');
    });

    test('updateMode plugin failure prevents DB write', () async {
      final database = _FakeLocalDatabase()..queryRows = <Map<String, Object?>>[_modeRow()];
      final restrictions = _FakeAppRestrictionManager()..throwOnUpsert = true;
      final repository = ModesRepositoryImpl(
        localDatabase: database,
        platform: PauzaPlatform.android,
        restrictions: restrictions,
      );

      final request = const ModeUpsertDTO.initialForDevice(
        hasNfcSupport: true,
      ).copyWith(title: 'Focus', textOnScreen: 'Stay focused', blockedAppIds: const ISet<AppIdentifier>.empty());

      await expectLater(repository.updateMode(modeId: 'mode-1', request: request), throwsA(isA<StateError>()));

      expect(database.transactionCalls, 0);
    });

    test('updateMode DB failure compensates by re-upserting previous mode', () async {
      final database = _FakeLocalDatabase()
        ..queryRows = <Map<String, Object?>>[_modeRow(blockedApps: 'app.old')]
        ..throwOnTransaction = true;
      final restrictions = _FakeAppRestrictionManager();
      final repository = ModesRepositoryImpl(
        localDatabase: database,
        platform: PauzaPlatform.android,
        restrictions: restrictions,
      );

      final request = const ModeUpsertDTO.initialForDevice(hasNfcSupport: true).copyWith(
        title: 'Focus next',
        textOnScreen: 'Stay focused',
        blockedAppIds: const ISetConst(<AppIdentifier>{AppIdentifier('app.new')}),
      );

      await expectLater(repository.updateMode(modeId: 'mode-1', request: request), throwsA(isA<StateError>()));

      expect(restrictions.upsertedModes, hasLength(2));
      expect(restrictions.upsertedModes.first.blockedAppIds, <AppIdentifier>[const AppIdentifier('app.new')]);
      expect(restrictions.upsertedModes.last.blockedAppIds, <AppIdentifier>[const AppIdentifier('app.old')]);
    });

    test('deleteMode calls plugin removeMode', () async {
      final database = _FakeLocalDatabase()..queryRows = <Map<String, Object?>>[_modeRow()];
      final restrictions = _FakeAppRestrictionManager();
      final repository = ModesRepositoryImpl(
        localDatabase: database,
        platform: PauzaPlatform.android,
        restrictions: restrictions,
      );

      await repository.deleteMode('mode-1');

      expect(restrictions.removedModeIds, <String>['mode-1']);
      expect(database.rawDeleteCalls, 1);
    });

    test('deleteMode plugin failure prevents DB delete', () async {
      final database = _FakeLocalDatabase()..queryRows = <Map<String, Object?>>[_modeRow()];
      final restrictions = _FakeAppRestrictionManager()..throwOnRemove = true;
      final repository = ModesRepositoryImpl(
        localDatabase: database,
        platform: PauzaPlatform.android,
        restrictions: restrictions,
      );

      await expectLater(repository.deleteMode('mode-1'), throwsA(isA<StateError>()));

      expect(database.rawDeleteCalls, 0);
    });

    test('deleteMode DB failure compensates by re-upserting previous mode', () async {
      final database = _FakeLocalDatabase()
        ..queryRows = <Map<String, Object?>>[_modeRow(blockedApps: 'app.old')]
        ..throwOnRawDelete = true;
      final restrictions = _FakeAppRestrictionManager();
      final repository = ModesRepositoryImpl(
        localDatabase: database,
        platform: PauzaPlatform.android,
        restrictions: restrictions,
      );

      await expectLater(repository.deleteMode('mode-1'), throwsA(isA<StateError>()));

      expect(restrictions.removedModeIds, <String>['mode-1']);
      expect(restrictions.upsertedModes, hasLength(1));
      expect(restrictions.upsertedModes.single.blockedAppIds, <AppIdentifier>[const AppIdentifier('app.old')]);
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
      final repository = ModesRepositoryImpl(
        localDatabase: database,
        platform: PauzaPlatform.android,
        restrictions: _FakeAppRestrictionManager(),
      );

      final modes = await repository.getModes();

      expect(modes, hasLength(1));
      expect(modes.first.icon, ModeIconCatalog.defaultIcon);
      expect(modes.first.minimumDuration, const Duration(minutes: 15));
      expect(modes.first.endingPausingScenario, ModeEndingPausingScenario.manual);
    });

    test('watchModes emits on changes', () async {
      final database = _FakeLocalDatabase()..queryRows = <Map<String, Object?>>[_modeRow()];
      final restrictions = _FakeAppRestrictionManager();
      final repository = ModesRepositoryImpl(
        localDatabase: database,
        platform: PauzaPlatform.android,
        restrictions: restrictions,
      );

      final request = const ModeUpsertDTO.initialForDevice(
        hasNfcSupport: true,
      ).copyWith(title: 'Focus', textOnScreen: 'Stay focused', blockedAppIds: const ISet<AppIdentifier>.empty());

      final stream = repository.watchModes();
      final expectation = expectLater(stream, emitsInOrder(<dynamic>[null, null, null]));

      await repository.createMode(request);
      await repository.updateMode(modeId: 'mode-1', request: request);
      await repository.deleteMode('mode-1');

      await expectation;
      repository.dispose();
    });
  });
}

Map<String, Object?> _modeRow({String blockedApps = ''}) {
  final now = DateTime.now().toUtc().millisecondsSinceEpoch;
  return <String, Object?>{
    'id': 'mode-1',
    'title': 'Focus',
    'text_on_screen': 'Stay focused',
    'description': null,
    'allowed_pauses_count': 1,
    'minimum_duration_ms': 900000,
    'ending_pausing_scenario': 'manual',
    'icon_token': ModeIconCatalog.defaultToken,
    'created_at': now,
    'updated_at': now,
    'schedule_days': null,
    'schedule_start_minute': null,
    'schedule_end_minute': null,
    'schedule_enabled': null,
    'blocked_apps': blockedApps,
  };
}

final class _FakeAppRestrictionManager extends AppRestrictionManager {
  final List<RestrictionMode> upsertedModes = <RestrictionMode>[];
  final List<String> removedModeIds = <String>[];
  bool throwOnUpsert = false;
  bool throwOnRemove = false;

  @override
  Future<void> upsertMode(RestrictionMode mode) async {
    if (throwOnUpsert) {
      throw StateError('plugin upsert failed');
    }
    upsertedModes.add(mode);
  }

  @override
  Future<void> removeMode(String modeId) async {
    if (throwOnRemove) {
      throw StateError('plugin remove failed');
    }
    removedModeIds.add(modeId);
  }
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
  int transactionCalls = 0;
  int rawDeleteCalls = 0;
  bool throwOnTransaction = false;
  bool throwOnRawDelete = false;

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
  Future<int> rawDelete(String sql, [List<Object?>? arguments]) async {
    rawDeleteCalls += 1;
    if (throwOnRawDelete) {
      throw StateError('db delete failed');
    }
    return 1;
  }

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
    transactionCalls += 1;
    if (throwOnTransaction) {
      throw StateError('db transaction failed');
    }
    return action(fakeTransaction);
  }
}
