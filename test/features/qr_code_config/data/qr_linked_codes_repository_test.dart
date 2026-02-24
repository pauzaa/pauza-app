import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/core/local_database/local_database.dart';
import 'package:pauza/src/features/qr_code_config/data/qr_code_config_error.dart';
import 'package:pauza/src/features/qr_code_config/data/qr_linked_codes_repository.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('QrLinkedCodesRepositoryImpl', () {
    test('generateAndLinkCode inserts row and returns linked code', () async {
      final localDatabase = _FakeLocalDatabase();
      final repository = QrLinkedCodesRepositoryImpl(
        localDatabase: localDatabase,
        uuid: _SequenceUuid(<String>['3f2504e0-4f89-41d3-9a0c-0305e82c3301', 'id-1']),
      );

      final code = await repository.generateAndLinkCode();

      expect(code.scanValue.normalized, 'pauza:qr:v1:3f2504e0-4f89-41d3-9a0c-0305e82c3301');
      expect(code.name, code.scanValue.normalized);
      expect(localDatabase.rowsById[code.id], isNotNull);
    });

    test('getLinkedCodes returns rows ordered by created_at desc', () async {
      final localDatabase = _FakeLocalDatabase();
      localDatabase.insertDirect(
        id: 'id-old',
        scanValue: 'pauza:qr:v1:3f2504e0-4f89-41d3-9a0c-0305e82c3301',
        name: 'old',
        createdAt: 100,
        updatedAt: 100,
      );
      localDatabase.insertDirect(
        id: 'id-new',
        scanValue: 'pauza:qr:v1:4f2504e0-4f89-41d3-9a0c-0305e82c3301',
        name: 'new',
        createdAt: 200,
        updatedAt: 200,
      );
      final repository = QrLinkedCodesRepositoryImpl(localDatabase: localDatabase);

      final linkedCodes = await repository.getLinkedCodes();

      expect(linkedCodes.map((code) => code.id).toIList(), ['id-new', 'id-old'].lock);
    });

    test('hasScanValue returns true for normalized valid scan', () async {
      final localDatabase = _FakeLocalDatabase();
      localDatabase.insertDirect(
        id: 'id-1',
        scanValue: 'pauza:qr:v1:3f2504e0-4f89-41d3-9a0c-0305e82c3301',
        name: 'code-1',
        createdAt: 100,
        updatedAt: 100,
      );
      final repository = QrLinkedCodesRepositoryImpl(localDatabase: localDatabase);

      final found = await repository.hasScanValue(scanValue: '  PAUZA:QR:V1:3F2504E0-4F89-41D3-9A0C-0305E82C3301  ');

      expect(found, isTrue);
    });

    test('hasScanValue returns false for unknown valid scan', () async {
      final localDatabase = _FakeLocalDatabase();
      final repository = QrLinkedCodesRepositoryImpl(localDatabase: localDatabase);

      final found = await repository.hasScanValue(scanValue: 'pauza:qr:v1:3f2504e0-4f89-41d3-9a0c-0305e82c3301');

      expect(found, isFalse);
    });

    test('hasLinkedCodes returns false when no codes exist', () async {
      final localDatabase = _FakeLocalDatabase();
      final repository = QrLinkedCodesRepositoryImpl(localDatabase: localDatabase);

      final hasLinkedCodes = await repository.hasLinkedCodes();

      expect(hasLinkedCodes, isFalse);
    });

    test('hasLinkedCodes returns true when at least one code exists', () async {
      final localDatabase = _FakeLocalDatabase();
      localDatabase.insertDirect(
        id: 'id-1',
        scanValue: 'pauza:qr:v1:3f2504e0-4f89-41d3-9a0c-0305e82c3301',
        name: 'code-1',
        createdAt: 100,
        updatedAt: 100,
      );
      final repository = QrLinkedCodesRepositoryImpl(localDatabase: localDatabase);

      final hasLinkedCodes = await repository.hasLinkedCodes();

      expect(hasLinkedCodes, isTrue);
    });

    test('hasScanValue throws for malformed scan value', () async {
      final localDatabase = _FakeLocalDatabase();
      final repository = QrLinkedCodesRepositoryImpl(localDatabase: localDatabase);

      expect(
        () => repository.hasScanValue(scanValue: 'not-a-valid-token'),
        throwsA(isA<QrCodeConfigInvalidScanValueError>()),
      );
    });

    test('renameCode trims and persists name, rejects empty', () async {
      final localDatabase = _FakeLocalDatabase();
      localDatabase.insertDirect(
        id: 'id-1',
        scanValue: 'pauza:qr:v1:3f2504e0-4f89-41d3-9a0c-0305e82c3301',
        name: 'old',
        createdAt: 100,
        updatedAt: 100,
      );
      final repository = QrLinkedCodesRepositoryImpl(localDatabase: localDatabase);

      await repository.renameCode(id: 'id-1', name: '  New Name  ');
      expect(localDatabase.rowsById['id-1']?['name'], 'New Name');

      expect(() => repository.renameCode(id: 'id-1', name: '   '), throwsA(isA<QrCodeConfigRenameFailedError>()));
    });

    test('deleteCode removes row', () async {
      final localDatabase = _FakeLocalDatabase();
      localDatabase.insertDirect(
        id: 'id-1',
        scanValue: 'pauza:qr:v1:3f2504e0-4f89-41d3-9a0c-0305e82c3301',
        name: 'code-1',
        createdAt: 100,
        updatedAt: 100,
      );
      final repository = QrLinkedCodesRepositoryImpl(localDatabase: localDatabase);

      await repository.deleteCode(id: 'id-1');

      expect(localDatabase.rowsById.containsKey('id-1'), isFalse);
    });

    test('generateAndLinkCode retries when duplicate scan token is generated', () async {
      final localDatabase = _FakeLocalDatabase();
      localDatabase.insertDirect(
        id: 'existing-id',
        scanValue: 'pauza:qr:v1:3f2504e0-4f89-41d3-9a0c-0305e82c3301',
        name: 'existing',
        createdAt: 100,
        updatedAt: 100,
      );
      final repository = QrLinkedCodesRepositoryImpl(
        localDatabase: localDatabase,
        uuid: _SequenceUuid(<String>[
          '3f2504e0-4f89-41d3-9a0c-0305e82c3301',
          'new-id-1',
          '4f2504e0-4f89-41d3-9a0c-0305e82c3301',
          'new-id-2',
        ]),
      );

      final code = await repository.generateAndLinkCode();

      expect(code.scanValue.normalized, 'pauza:qr:v1:4f2504e0-4f89-41d3-9a0c-0305e82c3301');
      expect(localDatabase.rowsById['new-id-2'], isNotNull);
    });
  });
}

final class _FakeLocalDatabase implements LocalDatabase {
  final Map<String, Map<String, Object?>> rowsById = <String, Map<String, Object?>>{};

  void insertDirect({
    required String id,
    required String scanValue,
    required String name,
    required int createdAt,
    required int updatedAt,
  }) {
    rowsById[id] = <String, Object?>{
      'id': id,
      'scan_value': scanValue,
      'name': name,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  bool get isOpen => true;

  @override
  Future<void> close() async {}

  @override
  Future<void> open() async {}

  @override
  Future<List<Map<String, Object?>>> rawQuery(String sql, [List<Object?>? arguments]) async {
    if (sql.contains('FROM qr_linked_codes') && sql.contains('ORDER BY created_at DESC')) {
      final rows = rowsById.values.map((row) => Map<String, Object?>.from(row)).toList(growable: false);
      rows.sort((left, right) => (right['created_at'] as int).compareTo(left['created_at'] as int));
      return rows;
    }

    if (sql.contains('SELECT 1 FROM qr_linked_codes WHERE scan_value = ? LIMIT 1')) {
      final scanValue = arguments?.first as String;
      final exists = rowsById.values.any((row) => row['scan_value'] == scanValue);
      return exists
          ? <Map<String, Object?>>[
              <String, Object?>{'1': 1},
            ]
          : const <Map<String, Object?>>[];
    }

    if (sql.contains('SELECT 1 FROM qr_linked_codes LIMIT 1')) {
      return rowsById.isNotEmpty
          ? <Map<String, Object?>>[
              <String, Object?>{'1': 1},
            ]
          : const <Map<String, Object?>>[];
    }

    throw UnsupportedError('Unsupported query: $sql');
  }

  @override
  Future<int> rawInsert(String sql, [List<Object?>? arguments]) async {
    if (!sql.contains('INSERT OR IGNORE INTO qr_linked_codes')) {
      throw UnsupportedError('Unsupported insert: $sql');
    }

    final args = arguments ?? const <Object?>[];
    final id = args[0] as String;
    final scanValue = args[1] as String;
    final alreadyExists = rowsById.values.any((row) => row['scan_value'] == scanValue);
    if (alreadyExists) {
      return 0;
    }

    rowsById[id] = <String, Object?>{
      'id': id,
      'scan_value': scanValue,
      'name': args[2] as String,
      'created_at': args[3] as int,
      'updated_at': args[4] as int,
    };
    return 1;
  }

  @override
  Future<int> rawUpdate(String sql, [List<Object?>? arguments]) async {
    if (!sql.contains('UPDATE qr_linked_codes')) {
      throw UnsupportedError('Unsupported update: $sql');
    }
    final args = arguments ?? const <Object?>[];
    final id = args[2] as String;
    final row = rowsById[id];
    if (row == null) {
      return 0;
    }
    row['name'] = args[0] as String;
    row['updated_at'] = args[1] as int;
    return 1;
  }

  @override
  Future<int> rawDelete(String sql, [List<Object?>? arguments]) async {
    if (!sql.contains('DELETE FROM qr_linked_codes WHERE id = ?')) {
      throw UnsupportedError('Unsupported delete: $sql');
    }
    final id = arguments?.first as String;
    return rowsById.remove(id) == null ? 0 : 1;
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
