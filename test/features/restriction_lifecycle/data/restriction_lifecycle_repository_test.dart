import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/core/local_database/local_database_service.dart';
import 'package:pauza/src/features/restriction_lifecycle/data/restriction_lifecycle_plugin_client.dart';
import 'package:pauza/src/features/restriction_lifecycle/data/restriction_lifecycle_repository.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  group('RestrictionLifecycleRepositoryImpl syncFromPluginQueue', () {
    test('duplicate event redelivery does not mutate session twice', () async {
      final localDatabase = _FakeLocalDatabase();
      final startEvent = _event(id: 'e1', sessionId: 's1', action: RestrictionLifecycleAction.start, occurredAtEpochMs: 1_000);
      final pluginClient = _FakeRestrictionLifecyclePluginClient(
        batches: <List<RestrictionLifecycleEvent>>[
          [startEvent],
          [startEvent],
          <RestrictionLifecycleEvent>[],
        ],
      );
      final repository = RestrictionLifecycleRepositoryImpl(localDatabase: localDatabase, pluginClient: pluginClient);

      await repository.syncFromPluginQueue();

      expect(localDatabase.eventRows.length, 1);
      expect(localDatabase.sessionRows.length, 1);
      expect(localDatabase.sessionRows['s1']?['last_event_id'], 'e1');
    });

    test('ack is called after transaction commit', () async {
      final localDatabase = _FakeLocalDatabase();
      final pluginClient = _FakeRestrictionLifecyclePluginClient(
        batches: <List<RestrictionLifecycleEvent>>[
          [_event(id: 'e1', sessionId: 's1', action: RestrictionLifecycleAction.start, occurredAtEpochMs: 1_000)],
          <RestrictionLifecycleEvent>[],
        ],
        onAck: () {
          expect(localDatabase.committedTransactions, greaterThan(0));
        },
      );
      final repository = RestrictionLifecycleRepositoryImpl(localDatabase: localDatabase, pluginClient: pluginClient);

      await repository.syncFromPluginQueue();

      expect(pluginClient.acknowledgedThroughEventIds, ['e1']);
    });

    test('upsert applies initial and subsequent events into one session row', () async {
      final localDatabase = _FakeLocalDatabase();
      final pluginClient = _FakeRestrictionLifecyclePluginClient(
        batches: <List<RestrictionLifecycleEvent>>[
          [
            _event(id: 'e1', sessionId: 's1', action: RestrictionLifecycleAction.start, occurredAtEpochMs: 1_000),
            _event(id: 'e2', sessionId: 's1', action: RestrictionLifecycleAction.pause, occurredAtEpochMs: 2_000),
            _event(id: 'e3', sessionId: 's1', action: RestrictionLifecycleAction.resume, occurredAtEpochMs: 3_000),
          ],
          <RestrictionLifecycleEvent>[],
        ],
      );
      final repository = RestrictionLifecycleRepositoryImpl(localDatabase: localDatabase, pluginClient: pluginClient);

      await repository.syncFromPluginQueue();

      final row = localDatabase.sessionRows['s1'];
      expect(row, isNotNull);
      expect(row?['pause_count'], 1);
      expect(row?['total_paused_ms'], 1_000);
      expect(row?['last_paused_at'], isNull);
      expect(row?['last_event_id'], 'e3');
    });
  });
}

RestrictionLifecycleEvent _event({
  required String id,
  required String sessionId,
  required RestrictionLifecycleAction action,
  required int occurredAtEpochMs,
}) {
  return RestrictionLifecycleEvent(
    id: id,
    sessionId: sessionId,
    modeId: 'mode-1',
    action: action,
    source: RestrictionLifecycleSource.manual,
    reason: 'test',
    occurredAt: DateTime.fromMillisecondsSinceEpoch(occurredAtEpochMs, isUtc: true),
  );
}

final class _FakeRestrictionLifecyclePluginClient implements RestrictionLifecyclePluginClient {
  _FakeRestrictionLifecyclePluginClient({required List<List<RestrictionLifecycleEvent>> batches, this.onAck}) : _batches = batches;

  final List<List<RestrictionLifecycleEvent>> _batches;
  final void Function()? onAck;
  final List<String> acknowledgedThroughEventIds = <String>[];

  @override
  Future<IList<RestrictionLifecycleEvent>> getPendingLifecycleEvents({int limit = 200}) async {
    if (_batches.isEmpty) {
      return const IListConst<RestrictionLifecycleEvent>([]);
    }
    final next = _batches.removeAt(0);
    return next.toIList();
  }

  @override
  Future<void> ackLifecycleEvents({required String throughEventId}) async {
    acknowledgedThroughEventIds.add(throughEventId);
    onAck?.call();
  }
}

final class _FakeLocalDatabase implements LocalDatabase {
  final Map<String, Map<String, Object?>> eventRows = <String, Map<String, Object?>>{};
  final Map<String, Map<String, Object?>> sessionRows = <String, Map<String, Object?>>{};

  int committedTransactions = 0;

  @override
  bool get isOpen => true;

  @override
  Future<void> close() async {}

  @override
  Future<void> open() async {}

  @override
  Future<List<Map<String, Object?>>> rawQuery(String sql, [List<Object?>? arguments]) async {
    if (sql.contains('FROM restriction_sessions')) {
      final rows = sessionRows.values.toList(growable: false);
      rows.sort((a, b) => (b['started_at'] as int).compareTo(a['started_at'] as int));
      return rows;
    }
    if (sql.contains('FROM restriction_lifecycle_events')) {
      return eventRows.values.toList(growable: false);
    }
    throw UnsupportedError('Unsupported query in fake database.');
  }

  @override
  Future<int> rawInsert(String sql, [List<Object?>? arguments]) async {
    throw UnsupportedError('Not used directly in repository tests.');
  }

  @override
  Future<int> rawUpdate(String sql, [List<Object?>? arguments]) async {
    throw UnsupportedError('Not used directly in repository tests.');
  }

  @override
  Future<int> rawDelete(String sql, [List<Object?>? arguments]) async {
    throw UnsupportedError('Not used directly in repository tests.');
  }

  @override
  Future<T> read<T>(Future<T> Function(DatabaseExecutor database) action) async {
    throw UnsupportedError('Not used directly in repository tests.');
  }

  @override
  Future<T> write<T>(Future<T> Function(DatabaseExecutor database) action) async {
    throw UnsupportedError('Not used directly in repository tests.');
  }

  @override
  Future<T> transaction<T>(Future<T> Function(Transaction transaction) action) async {
    final transaction = _FakeTransaction(eventRows: eventRows, sessionRows: sessionRows);
    final result = await action(transaction);
    committedTransactions += 1;
    return result;
  }
}

final class _FakeTransaction implements Transaction {
  _FakeTransaction({required this.eventRows, required this.sessionRows});

  final Map<String, Map<String, Object?>> eventRows;
  final Map<String, Map<String, Object?>> sessionRows;

  @override
  Future<int> rawInsert(String sql, [List<Object?>? arguments]) async {
    final args = arguments ?? const <Object?>[];
    if (sql.contains('INSERT OR IGNORE INTO restriction_lifecycle_events')) {
      final eventId = args[0]! as String;
      if (eventRows.containsKey(eventId)) {
        return 0;
      }
      eventRows[eventId] = <String, Object?>{
        'id': args[0],
        'session_id': args[1],
        'mode_id': args[2],
        'action': args[3],
        'source': args[4],
        'reason': args[5],
        'occurred_at': args[6],
        'created_at': args[7],
      };
      return 1;
    }

    if (sql.contains('INSERT INTO restriction_sessions')) {
      final sessionId = args[0]! as String;
      sessionRows[sessionId] = <String, Object?>{
        'session_id': args[0],
        'mode_id': args[1],
        'source': args[2],
        'started_at': args[3],
        'ended_at': args[4],
        'pause_count': args[5],
        'total_paused_ms': args[6],
        'last_paused_at': args[7],
        'integrity_status': args[8],
        'last_anomaly_reason': args[9],
        'last_event_id': args[10],
        'created_at': args[11],
        'updated_at': args[12],
      };
      return 1;
    }

    throw UnsupportedError('Unsupported rawInsert in fake transaction.');
  }

  @override
  Future<List<Map<String, Object?>>> rawQuery(String sql, [List<Object?>? arguments]) async {
    if (sql.contains('FROM restriction_sessions')) {
      final sessionId = arguments?.first as String;
      final row = sessionRows[sessionId];
      return row == null ? const <Map<String, Object?>>[] : <Map<String, Object?>>[row];
    }
    throw UnsupportedError('Unsupported rawQuery in fake transaction.');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
