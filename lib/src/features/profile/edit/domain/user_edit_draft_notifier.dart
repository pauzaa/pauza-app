import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pauza/src/core/common/validation.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/profile/common/model/user_dto.dart';
import 'package:pauza/src/features/profile/edit/bloc/user_name_checker_bloc.dart';
import 'package:pauza/src/features/profile/edit/model/user_edit.dart';

class UserEditDraftNotifier extends ValueNotifier<ProfileEditDTO> {
  UserEditDraftNotifier() : super(const ProfileEditDTO.initial());

  int _revision = 0;

  int get revision => _revision;

  void replace(UserDto request) {
    _revision++;
    value = ProfileEditDTO.fromUserDto(request);
  }

  bool canSubmit(UserDto user) {
    return value.name != user.name ||
        value.username != user.username ||
        value.profilePictureUrl != user.profilePicture ||
        value.profilePictureBytes != null;
  }

  String? validateName(AppLocalizations l10n) {
    return PauzaValidators.validateName(value.name, l10n);
  }

  String? validateUsername(AppLocalizations l10n, UsernameAvailability usernameAvailability) {
    return PauzaValidators.validateUsername(value.username, l10n, usernameAvailability);
  }

  void update({String? name, String? username, String? profilePictureUrl, Uint8List? profilePictureBytes}) {
    value = value.copyWith(name: name, username: username, profilePictureUrl: profilePictureUrl, profilePictureBytes: profilePictureBytes);
  }
}

class UserEditDraftScope extends InheritedNotifier<UserEditDraftNotifier> {
  const UserEditDraftScope({required super.notifier, required super.child, super.key});

  static UserEditDraftNotifier of(BuildContext context, {bool watch = true}) {
    final scope = watch
        ? context.dependOnInheritedWidgetOfExactType<UserEditDraftScope>()
        : context.getInheritedWidgetOfExactType<UserEditDraftScope>();
    assert(scope != null, 'User edit draft scope is missing in widget tree.');
    return scope!.notifier!;
  }
}
