import 'package:flutter/material.dart';
import 'package:pauza/src/features/modes/common/model/mode_upsert_request.dart';

class ModeUpsertDraftNotifier extends ValueNotifier<ModeUpsertDTO> {
  ModeUpsertDraftNotifier() : super(ModeUpsertDTO.empty);

  int _revision = 0;

  int get revision => _revision;

  void update(ModeUpsertDTO Function(ModeUpsertDTO current) updater) {
    value = updater(value);
  }

  void replace(ModeUpsertDTO request) {
    _revision++;
    value = request;
  }
}

class ModeUpsertScope extends InheritedNotifier<ModeUpsertDraftNotifier> {
  const ModeUpsertScope({required super.notifier, required super.child, super.key});

  static ModeUpsertDraftNotifier watch(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ModeUpsertScope>();
    assert(scope != null, 'Mode upsert scope is missing in widget tree.');
    return scope!.notifier!;
  }
}
