import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/app/root_scope.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/modes/select_apps/bloc/installed_apps_bloc.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class AndroidAppsBottomSheet extends StatelessWidget {
  const AndroidAppsBottomSheet({
    required this.initialSelectedAppIds,
    super.key,
  });

  final Set<AppIdentifier> initialSelectedAppIds;

  static Future<Set<AppIdentifier>?> show(
    BuildContext context, {
    required Set<AppIdentifier> initialSelectedAppIds,
  }) {
    return showModalBottomSheet<Set<AppIdentifier>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) =>
          AndroidAppsBottomSheet(initialSelectedAppIds: initialSelectedAppIds),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InstalledAppsBloc(
        installedAppsRepository: RootScope.of(context).installedAppsRepository,
      )..add(const InstalledAppsRequested(includeSystemApps: true)),
      child: _AndroidAppsBottomSheetContent(initialSelectedAppIds),
    );
  }
}

class _AndroidAppsBottomSheetContent extends StatefulWidget {
  const _AndroidAppsBottomSheetContent(this.initialSelectedAppIds);
  final Set<AppIdentifier> initialSelectedAppIds;

  @override
  State<_AndroidAppsBottomSheetContent> createState() =>
      _AndroidAppsBottomSheetContentState();
}

class _AndroidAppsBottomSheetContentState
    extends State<_AndroidAppsBottomSheetContent> {
  late final Set<AppIdentifier> _selectedAppIds = Set<AppIdentifier>.from(
    widget.initialSelectedAppIds,
  );

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
    context.read<InstalledAppsBloc>().add(
      InitialAppsSearched(searchQuery: searchQuery),
    );
  }

  void onDonePressed() {
    Navigator.of(context).pop(_selectedAppIds);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InstalledAppsBloc, InstalledAppsState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.hasError) {
          return Center(child: Text(context.l10n.modeAppsLoadFailedMessage));
        }

        final groupedApps = state.groupedApps;

        return BottomSheetScaffold(
          title: Text(context.l10n.selectAppsTitle),
          footer: PauzaFilledButton(
            onPressed: onDonePressed,
            title: Text(context.l10n.doneButton),
            width: double.infinity,
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: PauzaSpacing.medium,
                ),
                child: PauzaTextFormField(
                  onChanged: onSearchChanged,
                  decoration: PauzaInputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: context.l10n.modeBlockedAppsSearchLabel,
                  ),
                ),
              ),
              const SizedBox(height: PauzaSpacing.regular),
              Expanded(
                child: ListView.builder(
                  itemCount: groupedApps.length,
                  itemBuilder: (context, index) {
                    final category = groupedApps.keys.elementAt(index);
                    final apps = groupedApps.values.elementAt(index);
                    final categoryName = category == 'Other'
                        ? context.l10n.otherAppsCategory
                        : category;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            PauzaSpacing.medium,
                            PauzaSpacing.regular,
                            PauzaSpacing.medium,
                            PauzaSpacing.small,
                          ),
                          child: Text(
                            categoryName,
                            style: context.textTheme.titleMedium?.copyWith(
                              color: context.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ...apps.map(
                          (app) => ListTile(
                            leading: app.icon != null
                                ? Image.memory(app.icon!, width: 40, height: 40)
                                : const Icon(Icons.android),
                            title: Text(app.name),
                            trailing: PauzaCheckbox(
                              value: _selectedAppIds.contains(app.packageId),
                              onChanged: (_) => toggle(app.packageId),
                            ),
                            onTap: () => toggle(app.packageId),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: PauzaSpacing.medium,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
