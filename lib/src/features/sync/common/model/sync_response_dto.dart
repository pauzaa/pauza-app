import 'package:flutter/foundation.dart';

@immutable
final class SyncResponseDto {
  const SyncResponseDto({
    required this.serverTime,
    required this.tables,
  });

  final int serverTime;
  final Map<String, SyncTableResponseDto> tables;

  factory SyncResponseDto.fromJson(Map<String, Object?> json) {
    final tablesJson = json['tables'] as Map<String, Object?>;
    return SyncResponseDto(
      serverTime: json['server_time'] as int,
      tables: tablesJson.map(
        (key, value) => MapEntry(
          key,
          SyncTableResponseDto.fromJson(value! as Map<String, Object?>),
        ),
      ),
    );
  }

  @override
  String toString() =>
      'SyncResponseDto(serverTime: $serverTime, tables: ${tables.keys})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncResponseDto &&
          other.serverTime == serverTime &&
          _mapsEqual(tables, other.tables);

  @override
  int get hashCode => Object.hash(serverTime, tables);

  static bool _mapsEqual(
    Map<String, SyncTableResponseDto> a,
    Map<String, SyncTableResponseDto> b,
  ) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (a[key] != b[key]) return false;
    }
    return true;
  }
}

@immutable
final class SyncTableResponseDto {
  const SyncTableResponseDto({
    this.upserts = const [],
    this.deletions = const [],
  });

  final List<Map<String, Object?>> upserts;
  final List<Object> deletions;

  factory SyncTableResponseDto.fromJson(Map<String, Object?> json) {
    final rawUpserts = json['upserts'] as List<Object?>? ?? const [];
    final rawDeletions = json['deletions'] as List<Object?>? ?? const [];
    return SyncTableResponseDto(
      upserts: rawUpserts.cast<Map<String, Object?>>(),
      deletions: rawDeletions.cast<Object>(),
    );
  }

  @override
  String toString() =>
      'SyncTableResponseDto(upserts: ${upserts.length}, '
      'deletions: ${deletions.length})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncTableResponseDto &&
          listEquals(other.upserts, upserts) &&
          listEquals(other.deletions, deletions);

  @override
  int get hashCode => Object.hash(upserts, deletions);
}
