import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/core/local_database/pauza_local_database_schema_v1.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  test('onUpgrade from v1 to v2 adds nfc_linked_chips table', () async {
    final database = _FakeDatabase();
    const schema = PauzaLocalDatabaseSchemaV1();

    await schema.onUpgrade(database, 1, 2);

    expect(database.executedSql, hasLength(1));
    expect(
      database.executedSql.single,
      contains('CREATE TABLE nfc_linked_chips'),
    );
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
