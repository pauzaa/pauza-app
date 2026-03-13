import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:pauza/src/core/local_database/local_database.dart';
import 'package:pauza/src/features/qr_code_config/data/qr_code_config_error.dart';
import 'package:pauza/src/features/qr_code_config/model/qr_linked_code.dart';
import 'package:pauza/src/features/qr_code_config/model/qr_unlock_token.dart';
import 'package:pauza/src/features/sync/common/model/sync_table.dart';
import 'package:pauza/src/features/sync/data/sync_local_data_source.dart';
import 'package:qr/qr.dart';
import 'package:uuid/uuid.dart';

abstract interface class QrLinkedCodesRepository {
  Future<IList<QrLinkedCode>> getLinkedCodes();

  Future<QrLinkedCode> generateAndLinkCode();

  Future<void> deleteCode({required String id});

  Future<void> renameCode({required String id, required String name});

  Future<bool> hasScanValue({required String scanValue});

  Future<bool> hasLinkedCodes();
}

final class QrLinkedCodesRepositoryImpl implements QrLinkedCodesRepository {
  QrLinkedCodesRepositoryImpl({
    required LocalDatabase localDatabase,
    SyncLocalDataSource? syncLocalDataSource,
    Uuid? uuid,
  }) : _localDatabase = localDatabase,
       _syncLocalDataSource = syncLocalDataSource,
       _uuid = uuid ?? const Uuid();

  final LocalDatabase _localDatabase;
  final SyncLocalDataSource? _syncLocalDataSource;
  final Uuid _uuid;

  @override
  Future<IList<QrLinkedCode>> getLinkedCodes() async {
    final rows = await _localDatabase.rawQuery('''
SELECT
  id,
  scan_value,
  name,
  created_at,
  updated_at
FROM qr_linked_codes
ORDER BY created_at DESC
''');

    return rows.map(QrLinkedCode.fromDbRow).toIList();
  }

  @override
  Future<QrLinkedCode> generateAndLinkCode() async {
    try {
      for (var attempt = 0; attempt < 3; attempt += 1) {
        final token = QrUnlockToken.generate(uuid: _uuid);
        try {
          QrCode.fromData(data: token.normalized, errorCorrectLevel: QrErrorCorrectLevel.L);
        } on Object catch (error) {
          throw QrCodeConfigGenerationError(cause: error);
        }

        final now = DateTime.now().toUtc().millisecondsSinceEpoch;
        final id = _uuid.v4();
        final inserted = await _localDatabase.rawInsert(
          '''
INSERT OR IGNORE INTO qr_linked_codes (
  id,
  scan_value,
  name,
  created_at,
  updated_at
) VALUES (?, ?, ?, ?, ?)
''',
          [id, token.normalized, token.normalized, now, now],
        );

        if (inserted > 0) {
          final timestamp = DateTime.fromMillisecondsSinceEpoch(now, isUtc: true);
          return QrLinkedCode(
            id: id,
            scanValue: token,
            name: token.normalized,
            createdAt: timestamp,
            updatedAt: timestamp,
          );
        }
      }

      throw QrCodeConfigGenerationError(
        cause: StateError('Failed to generate unique QR unlock token after 3 attempts'),
      );
    } on QrCodeConfigError {
      rethrow;
    } on Object catch (error) {
      throw QrCodeConfigGenerationError(cause: error);
    }
  }

  @override
  Future<void> deleteCode({required String id}) async {
    try {
      await _localDatabase.rawDelete('DELETE FROM qr_linked_codes WHERE id = ?', [id]);
      await _syncLocalDataSource?.trackDeletion(
        table: SyncTable.qrLinkedCodes,
        key: id,
      );
    } on Object catch (error) {
      throw QrCodeConfigDeleteFailedError(cause: error);
    }
  }

  @override
  Future<void> renameCode({required String id, required String name}) async {
    try {
      final normalizedName = name.trim();
      if (normalizedName.isEmpty) {
        throw ArgumentError.value(name, 'name', 'name must not be empty');
      }

      await _localDatabase.rawUpdate(
        '''
UPDATE qr_linked_codes
SET
  name = ?,
  updated_at = ?
WHERE id = ?
''',
        [normalizedName, DateTime.now().toUtc().millisecondsSinceEpoch, id],
      );
    } on Object catch (error) {
      throw QrCodeConfigRenameFailedError(cause: error);
    }
  }

  @override
  Future<bool> hasScanValue({required String scanValue}) async {
    final token = _parseTokenOrThrow(scanValue);
    final rows = await _localDatabase.rawQuery('SELECT 1 FROM qr_linked_codes WHERE scan_value = ? LIMIT 1', [
      token.normalized,
    ]);
    return rows.isNotEmpty;
  }

  @override
  Future<bool> hasLinkedCodes() async {
    final rows = await _localDatabase.rawQuery('SELECT 1 FROM qr_linked_codes LIMIT 1');
    return rows.isNotEmpty;
  }

  QrUnlockToken _parseTokenOrThrow(String scanValue) {
    try {
      return QrUnlockToken.parse(scanValue);
    } on Object catch (error) {
      throw QrCodeConfigInvalidScanValueError(scanValue: scanValue, cause: error);
    }
  }
}
