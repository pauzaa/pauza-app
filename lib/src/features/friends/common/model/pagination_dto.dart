import 'package:flutter/foundation.dart';

@immutable
final class PaginationDto {
  const PaginationDto({required this.page, required this.limit, required this.total});

  factory PaginationDto.fromJson(Map<String, Object?> json) => PaginationDto(
    page: json['page'] as int? ?? 1,
    limit: json['limit'] as int? ?? 20,
    total: json['total'] as int? ?? 0,
  );

  final int page;
  final int limit;
  final int total;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaginationDto && page == other.page && limit == other.limit && total == other.total;

  @override
  int get hashCode => Object.hash(page, limit, total);

  @override
  String toString() => 'PaginationDto(page: $page, limit: $limit, total: $total)';
}
