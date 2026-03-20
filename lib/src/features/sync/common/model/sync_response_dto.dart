import 'package:flutter/foundation.dart';

@immutable
final class SyncResponseDto {
  const SyncResponseDto({required this.tables});

  final Map<String, SyncTableResponseDto> tables;

  factory SyncResponseDto.fromJson(Map<String, Object?> json) {
    final tablesJson = json['tables'] as Map<String, Object?>;
    return SyncResponseDto(
      tables: tablesJson.map(
        (key, value) => MapEntry(key, SyncTableResponseDto.fromJson(value! as Map<String, Object?>)),
      ),
    );
  }

  @override
  String toString() => 'SyncResponseDto(tables: ${tables.keys})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SyncResponseDto && _mapsEqual(tables, other.tables);

  @override
  int get hashCode => tables.hashCode;

  static bool _mapsEqual(Map<String, SyncTableResponseDto> a, Map<String, SyncTableResponseDto> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (a[key] != b[key]) return false;
    }
    return true;
  }
}

@immutable
final class SyncTableResponseDto {
  const SyncTableResponseDto({required this.nextCursor, this.upserts = const [], this.deletions = const []});

  final int nextCursor;
  final List<Map<String, Object?>> upserts;
  final List<Object> deletions;

  factory SyncTableResponseDto.fromJson(Map<String, Object?> json) {
    final rawUpserts = json['upserts'] as List<Object?>? ?? const [];
    final rawDeletions = json['deletions'] as List<Object?>? ?? const [];
    return SyncTableResponseDto(
      nextCursor: json['next_cursor'] as int,
      upserts: rawUpserts.cast<Map<String, Object?>>(),
      deletions: rawDeletions.cast<Object>(),
    );
  }

  @override
  String toString() =>
      'SyncTableResponseDto(nextCursor: $nextCursor, '
      'upserts: ${upserts.length}, deletions: ${deletions.length})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncTableResponseDto &&
          other.nextCursor == nextCursor &&
          listEquals(other.upserts, upserts) &&
          listEquals(other.deletions, deletions);

  @override
  int get hashCode => Object.hash(nextCursor, upserts, deletions);
}
