import 'package:sqflite/sqflite.dart';

abstract interface class LocalDatabase {
  bool get isOpen;

  Future<void> open();

  Future<void> close();

  Future<T> read<T>(Future<T> Function(DatabaseExecutor database) action);

  Future<T> write<T>(Future<T> Function(DatabaseExecutor database) action);

  Future<T> transaction<T>(Future<T> Function(Transaction transaction) action);

  Future<List<Map<String, Object?>>> rawQuery(String sql, [List<Object?>? arguments]);

  Future<int> rawInsert(String sql, [List<Object?>? arguments]);

  Future<int> rawUpdate(String sql, [List<Object?>? arguments]);

  Future<int> rawDelete(String sql, [List<Object?>? arguments]);
}
