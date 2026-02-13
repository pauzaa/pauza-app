import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/app/root_scope.dart';
import 'package:pauza/src/features/modes/select_apps/bloc/installed_apps_bloc.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

class AndroidAppsBottomSheet extends StatelessWidget {
  const AndroidAppsBottomSheet({required this.initialSelectedAppIds, super.key});

  final Set<AppIdentifier> initialSelectedAppIds;

  static Future<Set<AppIdentifier>?> show(
    BuildContext context, {
    required Set<AppIdentifier> initialSelectedAppIds,
  }) {
    return showModalBottomSheet<Set<AppIdentifier>>(
      context: context,
      builder: (_) => AndroidAppsBottomSheet(initialSelectedAppIds: initialSelectedAppIds),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          InstalledAppsBloc(installedAppsRepository: RootScope.of(context).installedAppsRepository)
            ..add(const InstalledAppsRequested(includeSystemApps: true)),
      child: _AndroidAppsBottomSheetContent(initialSelectedAppIds),
    );
  }
}

class _AndroidAppsBottomSheetContent extends StatefulWidget {
  const _AndroidAppsBottomSheetContent(this.initialSelectedAppIds);
  final Set<AppIdentifier> initialSelectedAppIds;

  @override
  State<_AndroidAppsBottomSheetContent> createState() => _AndroidAppsBottomSheetContentState();
}

class _AndroidAppsBottomSheetContentState extends State<_AndroidAppsBottomSheetContent> {
  late final Set<AppIdentifier> _selectedAppIds = Set<AppIdentifier>.from(
    widget.initialSelectedAppIds,
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void toggle(AppIdentifier appId) {
    setState(() {
      if (_selectedAppIds.contains(appId)) {
        _selectedAppIds.remove(appId);
      } else {
        _selectedAppIds.add(appId);
      }
    });
  }

  void onSearchChanged(String searchQuery) {
    context.read<InstalledAppsBloc>().add(InitialAppsSearched(searchQuery: searchQuery));
  }

  void onDonePressed() {
    Navigator.of(context).pop(_selectedAppIds);
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
