import 'package:flutter/foundation.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';

@immutable
class ModeUpsertDTO {
  const ModeUpsertDTO({
    required this.title,
    required this.textOnScreen,
    required this.description,
    required this.allowedPausesCount,
    required this.isEnabled,
    required this.blockedAppIds,
  });

  static const ModeUpsertDTO empty = ModeUpsertDTO(
    title: '',
    textOnScreen: '',
    description: null,
    allowedPausesCount: 0,
    isEnabled: true,
    blockedAppIds: ISetConst(<String>{}),
  );

  final String title;
  final String textOnScreen;
  final String? description;
  final int allowedPausesCount;
  final bool isEnabled;
  final ISet<String> blockedAppIds;

  static const Object _descriptionNotProvided = Object();

  ModeUpsertDTO copyWith({
    String? title,
    String? textOnScreen,
    Object? description = _descriptionNotProvided,
    int? allowedPausesCount,
    bool? isEnabled,
    ISet<String>? blockedAppIds,
  }) => ModeUpsertDTO(
    title: title ?? this.title,
    textOnScreen: textOnScreen ?? this.textOnScreen,
    description: identical(description, _descriptionNotProvided)
        ? this.description
        : description as String?,
    allowedPausesCount: allowedPausesCount ?? this.allowedPausesCount,
    isEnabled: isEnabled ?? this.isEnabled,
    blockedAppIds: blockedAppIds ?? this.blockedAppIds,
  );

  @override
  String toString() {
    return 'ModeUpsertRequest('
        'title: $title, '
        'textOnScreen: $textOnScreen, '
        'description: $description, '
        'allowedPausesCount: $allowedPausesCount, '
        'isEnabled: $isEnabled, '
        'blockedAppIdsCount: ${blockedAppIds.length}'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    if (other is! ModeUpsertDTO || runtimeType != other.runtimeType) {
      return false;
    }

    return title == other.title &&
        textOnScreen == other.textOnScreen &&
        description == other.description &&
        allowedPausesCount == other.allowedPausesCount &&
        isEnabled == other.isEnabled &&
        blockedAppIds.equalItems(other.blockedAppIds);
  }

  @override
  int get hashCode => Object.hash(
    title,
    textOnScreen,
    description,
    allowedPausesCount,
    isEnabled,
    Object.hashAllUnordered(blockedAppIds),
  );
}
