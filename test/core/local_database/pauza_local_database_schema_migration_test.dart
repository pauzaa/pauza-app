import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/core/local_database/pauza_local_database_schema_v1.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  test('onUpgrade from v1 to v2 adds nfc_linked_chips table', () async {
    final database = _FakeDatabase();
    const schema = PauzaLocalDatabaseSchemaV1();

    await schema.onUpgrade(database, 1, 2);

    expect(database.executedSql, hasLength(1));
    expect(database.executedSql.single, contains('CREATE TABLE nfc_linked_chips'));
  });

  test('onUpgrade from v2 to v3 adds streak_session_daily_rollups table', () async {
    final database = _FakeDatabase();
    const schema = PauzaLocalDatabaseSchemaV1();

    await schema.onUpgrade(database, 2, 3);

    expect(database.executedSql.any((sql) => sql.contains('CREATE TABLE streak_session_daily_rollups')), isTrue);
  });

  test('onUpgrade from v2 to v3 adds streak_daily_aggregates table', () async {
    final database = _FakeDatabase();
    const schema = PauzaLocalDatabaseSchemaV1();

    await schema.onUpgrade(database, 2, 3);

    expect(database.executedSql.any((sql) => sql.contains('CREATE TABLE streak_daily_aggregates')), isTrue);
  });

  test('onUpgrade from v2 to v3 adds streak_rollup_state table', () async {
    final database = _FakeDatabase();
    const schema = PauzaLocalDatabaseSchemaV1();

    await schema.onUpgrade(database, 2, 3);

    expect(database.executedSql.any((sql) => sql.contains('CREATE TABLE streak_rollup_state')), isTrue);
  });

  test('onUpgrade from v2 to v3 seeds streak_rollup_state row', () async {
    final database = _FakeDatabase();
    const schema = PauzaLocalDatabaseSchemaV1();

    await schema.onUpgrade(database, 2, 3);

    expect(
      database.executedSql.any(
        (sql) => sql.contains('INSERT OR IGNORE INTO streak_rollup_state') && sql.contains('VALUES (1, 0, \'\', 0)'),
      ),
      isTrue,
    );
  });

  test('onUpgrade from v3 to v4 adds qr_linked_codes table', () async {
    final database = _FakeDatabase();
    const schema = PauzaLocalDatabaseSchemaV1();

    await schema.onUpgrade(database, 3, 4);

    expect(database.executedSql, hasLength(1));
    expect(database.executedSql.single, contains('CREATE TABLE qr_linked_codes'));
  });
}

final class _FakeDatabase implements Database {
  final List<String> executedSql = <String>[];

  @override
  Future<void> execute(String sql, [List<Object?>? arguments]) async {
    executedSql.add(sql);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
