import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:pauza/src/core/local_database/local_database.dart';
import 'package:pauza/src/features/nfc/model/nfc_chip_identifier.dart';
import 'package:pauza/src/features/nfc_chip_config/model/nfc_linked_chip.dart';
import 'package:pauza/src/features/sync/common/model/sync_table.dart';
import 'package:pauza/src/features/sync/data/sync_local_data_source.dart';
import 'package:pauza/src/features/sync/domain/sync_trigger.dart';
import 'package:uuid/uuid.dart';

abstract interface class NfcLinkedChipsRepository {
  Future<IList<NfcLinkedChip>> getLinkedChips();

  /// Returns `true` when the chip was linked, `false` when it already exists.
  Future<bool> linkChipIfAbsent({required NfcChipIdentifier chipIdentifier});

  Future<void> deleteChip({required String id});

  Future<bool> hasChip({required NfcChipIdentifier chipIdentifier});

  Future<bool> hasLinkedChips();

  Future<void> renameChip({required String id, required String name});
}

final class NfcLinkedChipsRepositoryImpl implements NfcLinkedChipsRepository {
  NfcLinkedChipsRepositoryImpl({
    required LocalDatabase localDatabase,
    SyncLocalDataSource? syncLocalDataSource,
    SyncTrigger? syncTrigger,
    Uuid? uuid,
  }) : _localDatabase = localDatabase,
       _syncLocalDataSource = syncLocalDataSource,
       _syncTrigger = syncTrigger,
       _uuid = uuid ?? const Uuid();

  final LocalDatabase _localDatabase;
  final SyncLocalDataSource? _syncLocalDataSource;
  final SyncTrigger? _syncTrigger;
  final Uuid _uuid;

  @override
  Future<IList<NfcLinkedChip>> getLinkedChips() async {
    final rows = await _localDatabase.rawQuery('''
SELECT
  id,
  chip_identifier,
  name,
  created_at,
  updated_at
FROM nfc_linked_chips
ORDER BY created_at DESC
''');

    return rows.map(NfcLinkedChip.fromDbRow).toIList();
  }

  @override
  Future<bool> linkChipIfAbsent({required NfcChipIdentifier chipIdentifier}) async {
    final normalizedChipIdentifier = chipIdentifier.normalized;
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;

    final inserted = await _localDatabase.rawInsert(
      '''
INSERT OR IGNORE INTO nfc_linked_chips (
  id,
  chip_identifier,
  name,
  created_at,
  updated_at
) VALUES (?, ?, ?, ?, ?)
''',
      [_uuid.v4(), normalizedChipIdentifier, normalizedChipIdentifier, now, now],
    );

    if (inserted > 0) {
      _syncTrigger?.notifyChange();
    }

    return inserted > 0;
  }

  @override
  Future<void> deleteChip({required String id}) async {
    await _localDatabase.rawDelete('DELETE FROM nfc_linked_chips WHERE id = ?', [id]);
    await _syncLocalDataSource?.trackDeletion(table: SyncTable.nfcLinkedChips, key: id);
    _syncTrigger?.notifyChange();
  }

  @override
  Future<bool> hasChip({required NfcChipIdentifier chipIdentifier}) async {
    final rows = await _localDatabase.rawQuery('SELECT 1 FROM nfc_linked_chips WHERE chip_identifier = ? LIMIT 1', [
      chipIdentifier.normalized,
    ]);

    return rows.isNotEmpty;
  }

  @override
  Future<bool> hasLinkedChips() async {
    final rows = await _localDatabase.rawQuery('SELECT 1 FROM nfc_linked_chips LIMIT 1');
    return rows.isNotEmpty;
  }

  @override
  Future<void> renameChip({required String id, required String name}) async {
    final normalizedName = name.trim();
    if (normalizedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'name must not be empty');
    }

    await _localDatabase.rawUpdate(
      '''
UPDATE nfc_linked_chips
SET
  name = ?,
  updated_at = ?
WHERE id = ?
''',
      [normalizedName, DateTime.now().toUtc().millisecondsSinceEpoch, id],
    );
    _syncTrigger?.notifyChange();
  }
}
