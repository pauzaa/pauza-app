import 'package:flutter/foundation.dart';
import 'package:pauza/src/features/nfc/model/nfc_ndef_record_dto.dart';
import 'package:pauza/src/features/nfc/model/nfc_tag_tech.dart';

@immutable
class NfcCardDto {
  const NfcCardDto({
    required this.id,
    required this.detectedAt,
    required this.uidHex,
    required this.techTypes,
    required this.isNdefFormatted,
    required this.ndefRecords,
    required this.rawSnapshot,
  });

  final String id;
  final DateTime detectedAt;
  final String? uidHex;
  final List<NfcTagTech> techTypes;
  final bool isNdefFormatted;
  final List<NfcNdefRecordDto> ndefRecords;
  final Map<String, Object?> rawSnapshot;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'detectedAt': detectedAt.toUtc().toIso8601String(),
      'uidHex': uidHex,
      'techTypes': techTypes.map((tech) => tech.name).toList(growable: false),
      'isNdefFormatted': isNdefFormatted,
      'ndefRecords': ndefRecords
          .map((record) => record.toJson())
          .toList(growable: false),
      'rawSnapshot': rawSnapshot,
    };
  }

  factory NfcCardDto.fromJson(Map<String, Object?> json) {
    final techTypesRaw = json['techTypes'];
    final techTypeValues = <NfcTagTech>[];
    if (techTypesRaw is List<Object?>) {
      for (final value in techTypesRaw) {
        if (value is! String) {
          continue;
        }
        final found = NfcTagTech.values.where((tech) => tech.name == value);
        if (found.isNotEmpty) {
          techTypeValues.add(found.first);
        }
      }
    }

    final ndefRecordsRaw = json['ndefRecords'];
    final ndefRecordValues = <NfcNdefRecordDto>[];
    if (ndefRecordsRaw is List<Object?>) {
      for (final record in ndefRecordsRaw) {
        if (record is Map<Object?, Object?>) {
          ndefRecordValues.add(
            NfcNdefRecordDto.fromJson(
              record.map(
                (key, value) =>
                    MapEntry(key is String ? key : key.toString(), value),
              ),
            ),
          );
        }
      }
    }

    final rawSnapshot = json['rawSnapshot'];

    return NfcCardDto(
      id: json['id'] as String? ?? '',
      detectedAt:
          DateTime.tryParse(json['detectedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      uidHex: json['uidHex'] as String?,
      techTypes: List<NfcTagTech>.unmodifiable(techTypeValues),
      isNdefFormatted: json['isNdefFormatted'] as bool? ?? false,
      ndefRecords: List<NfcNdefRecordDto>.unmodifiable(ndefRecordValues),
      rawSnapshot: rawSnapshot is Map<Object?, Object?>
          ? rawSnapshot.map(
              (key, value) =>
                  MapEntry(key is String ? key : key.toString(), value),
            )
          : const <String, Object?>{},
    );
  }

  @override
  String toString() {
    return 'NfcCardDto('
        'id: $id, '
        'detectedAt: $detectedAt, '
        'uidHex: $uidHex, '
        'techTypes: $techTypes, '
        'isNdefFormatted: $isNdefFormatted, '
        'ndefRecords: $ndefRecords, '
        'rawSnapshot: $rawSnapshot'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is NfcCardDto &&
        other.id == id &&
        other.detectedAt == detectedAt &&
        other.uidHex == uidHex &&
        listEquals(other.techTypes, techTypes) &&
        other.isNdefFormatted == isNdefFormatted &&
        listEquals(other.ndefRecords, ndefRecords) &&
        mapEquals(other.rawSnapshot, rawSnapshot);
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      detectedAt,
      uidHex,
      Object.hashAll(techTypes),
      isNdefFormatted,
      Object.hashAll(ndefRecords),
      Object.hashAll(
        rawSnapshot.entries
            .map((entry) => Object.hash(entry.key, entry.value))
            .toList(growable: false),
      ),
    );
  }
}
