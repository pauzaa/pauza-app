import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/core/local_database/local_database.dart';
import 'package:pauza/src/features/nfc/model/nfc_chip_identifier.dart';
import 'package:pauza/src/features/nfc_chip_config/data/nfc_linked_chips_repository.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('NfcLinkedChipsRepositoryImpl', () {
    test('hasLinkedChips returns false when no chips exist', () async {
      final localDatabase = _FakeLocalDatabase();
      final repository = NfcLinkedChipsRepositoryImpl(localDatabase: localDatabase);

      final hasLinkedChips = await repository.hasLinkedChips();

      expect(hasLinkedChips, isFalse);
    });

    test('hasLinkedChips returns true after linking a chip', () async {
      final localDatabase = _FakeLocalDatabase();
      final repository = NfcLinkedChipsRepositoryImpl(
        localDatabase: localDatabase,
        uuid: _SequenceUuid(<String>['chip-id-1']),
      );

      await repository.linkChipIfAbsent(chipIdentifier: NfcChipIdentifier.parse('a1b2'));

      final hasLinkedChips = await repository.hasLinkedChips();

      expect(hasLinkedChips, isTrue);
    });
  });
}

final class _FakeLocalDatabase implements LocalDatabase {
  final Map<String, Map<String, Object?>> rowsById = <String, Map<String, Object?>>{};

  @override
  bool get isOpen => true;

  @override
  Future<void> close() async {}

  @override
  Future<void> open() async {}

  @override
  Future<List<Map<String, Object?>>> rawQuery(String sql, [List<Object?>? arguments]) async {
    if (sql.contains('SELECT 1 FROM nfc_linked_chips LIMIT 1')) {
      return rowsById.isNotEmpty
          ? <Map<String, Object?>>[
              <String, Object?>{'1': 1},
            ]
          : const <Map<String, Object?>>[];
    }

    if (sql.contains('SELECT 1 FROM nfc_linked_chips WHERE chip_identifier = ? LIMIT 1')) {
      final chipIdentifier = arguments?.first as String;
      final exists = rowsById.values.any((row) => row['chip_identifier'] == chipIdentifier);
      return exists
          ? <Map<String, Object?>>[
              <String, Object?>{'1': 1},
            ]
          : const <Map<String, Object?>>[];
    }

    throw UnsupportedError('Unsupported query: $sql');
  }

  @override
  Future<int> rawInsert(String sql, [List<Object?>? arguments]) async {
    if (!sql.contains('INSERT OR IGNORE INTO nfc_linked_chips')) {
      throw UnsupportedError('Unsupported insert: $sql');
    }

    final args = arguments ?? const <Object?>[];
    final id = args[0] as String;
    final chipIdentifier = args[1] as String;
    final exists = rowsById.values.any((row) => row['chip_identifier'] == chipIdentifier);
    if (exists) {
      return 0;
    }

    rowsById[id] = <String, Object?>{
      'id': id,
      'chip_identifier': chipIdentifier,
      'name': args[2] as String,
      'created_at': args[3] as int,
      'updated_at': args[4] as int,
    };
    return 1;
  }

  @override
  Future<int> rawUpdate(String sql, [List<Object?>? arguments]) async {
    throw UnsupportedError('Unsupported update: $sql');
  }

  @override
  Future<int> rawDelete(String sql, [List<Object?>? arguments]) async {
    throw UnsupportedError('Unsupported delete: $sql');
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
    throw UnimplementedError();
  }
}

final class _SequenceUuid extends Uuid {
  _SequenceUuid(this._values);

  final List<String> _values;
  var _index = 0;

  @override
  String v4({Object? config, Map<String, dynamic>? options}) {
    if (_index >= _values.length) {
      throw StateError('No more UUID values');
    }
    final value = _values[_index];
    _index += 1;
    return value;
  }
}
