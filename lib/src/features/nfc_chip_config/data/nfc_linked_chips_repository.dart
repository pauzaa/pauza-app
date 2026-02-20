import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:pauza/src/core/local_database/local_database.dart';
import 'package:pauza/src/features/nfc_chip_config/data/nfc_chip_config_error.dart';
import 'package:pauza/src/features/nfc_chip_config/model/nfc_linked_chip.dart';
import 'package:uuid/uuid.dart';

abstract interface class NfcLinkedChipsRepository {
  Future<IList<NfcLinkedChip>> getLinkedChips();

  Future<bool> linkChipIfAbsent({required String chipIdentifier});

  Future<void> deleteChip({required String id});

  Future<bool> hasChip({required String chipIdentifier});

  Future<void> renameChip({required String id, required String name});
}

final class NfcLinkedChipsRepositoryImpl implements NfcLinkedChipsRepository {
  NfcLinkedChipsRepositoryImpl({required LocalDatabase localDatabase, Uuid? uuid})
    : _localDatabase = localDatabase,
      _uuid = uuid ?? const Uuid();

  final LocalDatabase _localDatabase;
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
  Future<bool> linkChipIfAbsent({required String chipIdentifier}) async {
    if (chipIdentifier.isEmpty) {
      throw const NfcChipConfigMissingIdentifierError();
    }

    final normalizedChipIdentifier = _normalizeChipIdentifier(chipIdentifier);
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

    return inserted > 0;
  }

  @override
  Future<void> deleteChip({required String id}) async {
    await _localDatabase.rawDelete('DELETE FROM nfc_linked_chips WHERE id = ?', [id]);
  }

  @override
  Future<bool> hasChip({required String chipIdentifier}) async {
    final normalizedChipIdentifier = _normalizeChipIdentifier(chipIdentifier);

    final rows = await _localDatabase.rawQuery('SELECT 1 FROM nfc_linked_chips WHERE chip_identifier = ? LIMIT 1', [
      normalizedChipIdentifier,
    ]);

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
  }

  String _normalizeChipIdentifier(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) {
      throw ArgumentError.value(value, 'chipIdentifier', 'chipIdentifier must not be empty');
    }

    return normalized;
  }
}
