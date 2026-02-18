import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

class SelectedAppsScope extends InheritedNotifier<SelectedAppsNotifier> {
  const SelectedAppsScope({required super.notifier, required super.child, super.key});

  static SelectedAppsNotifier of(BuildContext context, {bool watch = true}) {
    final scope = watch
        ? context.dependOnInheritedWidgetOfExactType<SelectedAppsScope>()
        : context.getInheritedWidgetOfExactType<SelectedAppsScope>();
    assert(scope != null, 'SelectedAppsScope not found in context');
    return scope!.notifier!;
  }

  static SelectedAppsNotifier? maybeOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<SelectedAppsScope>();
    return scope?.notifier;
  }
}

class SelectedAppsNotifier extends ChangeNotifier {
  SelectedAppsNotifier({ISet<AppIdentifier> initialSelected = const ISetConst(<AppIdentifier>{})}) : _selectedAppIds = initialSelected;

  ISet<AppIdentifier> _selectedAppIds;

  ISet<AppIdentifier> get selectedAppIds => _selectedAppIds;

  int get selectedCount => _selectedAppIds.length;

  bool isAppSelected(AppIdentifier appId) => _selectedAppIds.contains(appId);

  bool isCategoryFullySelected(IList<AppIdentifier> categoryAppIds) {
    if (categoryAppIds.isEmpty) {
      return false;
    }
    return categoryAppIds.every((appId) => _selectedAppIds.contains(appId));
  }

  void toggleApp(AppIdentifier appId) {
    if (_selectedAppIds.contains(appId)) {
      _selectedAppIds = _selectedAppIds.remove(appId);
    } else {
      _selectedAppIds = _selectedAppIds.add(appId);
    }
    notifyListeners();
  }

  void toggleCategory(IList<AppIdentifier> categoryAppIds, bool selectAll) {
    if (selectAll) {
      _selectedAppIds = _selectedAppIds.addAll(categoryAppIds);
    } else {
      _selectedAppIds = _selectedAppIds.removeAll(categoryAppIds);
    }
    notifyListeners();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SelectedAppsNotifier && other._selectedAppIds == _selectedAppIds;
  }

  @override
  int get hashCode => _selectedAppIds.hashCode;
}
