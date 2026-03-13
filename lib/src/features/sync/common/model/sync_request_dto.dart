import 'package:flutter/foundation.dart';
import 'package:pauza/src/features/sync/common/model/sync_table.dart';

@immutable
final class SyncRequestDto {
  const SyncRequestDto({required this.tables});

  factory SyncRequestDto.empty() {
    return SyncRequestDto(
      tables: {
        for (final table in SyncTable.values)
          table.key: const SyncTableRequestDto(lastSyncedAt: 0),
      },
    );
  }

  final Map<String, SyncTableRequestDto> tables;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'tables': tables.map(
        (key, table) => MapEntry(key, table.toJson()),
      ),
    };
  }

  @override
  String toString() => 'SyncRequestDto(tables: ${tables.keys})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncRequestDto &&
          _mapsEqual(tables, other.tables);

  @override
  int get hashCode => tables.hashCode;

  static bool _mapsEqual(
    Map<String, SyncTableRequestDto> a,
    Map<String, SyncTableRequestDto> b,
  ) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (a[key] != b[key]) return false;
    }
    return true;
  }
}

@immutable
final class SyncTableRequestDto {
  const SyncTableRequestDto({
    required this.lastSyncedAt,
    this.upserts = const [],
    this.deletions = const [],
  });

  final int lastSyncedAt;
  final List<Map<String, Object?>> upserts;
  final List<Object> deletions;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'last_synced_at': lastSyncedAt,
      'upserts': upserts,
      'deletions': deletions,
    };
  }

  @override
  String toString() =>
      'SyncTableRequestDto(lastSyncedAt: $lastSyncedAt, '
      'upserts: ${upserts.length}, deletions: ${deletions.length})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncTableRequestDto &&
          other.lastSyncedAt == lastSyncedAt &&
          listEquals(other.upserts, upserts) &&
          listEquals(other.deletions, deletions);

  @override
  int get hashCode => Object.hash(lastSyncedAt, upserts, deletions);
}
