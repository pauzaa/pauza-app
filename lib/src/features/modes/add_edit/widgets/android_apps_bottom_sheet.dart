import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/core/localization/gen/app_localizations.dart';
import 'package:pauza/src/features/modes/add_edit/bloc/installed_apps_bloc.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

class AndroidAppsBottomSheet extends StatefulWidget {
  const AndroidAppsBottomSheet({
    required this.initialSelectedAppIds,
    super.key,
  });

  final Set<String> initialSelectedAppIds;

  @override
  State<AndroidAppsBottomSheet> createState() => _AndroidAppsBottomSheetState();
}

class _AndroidAppsBottomSheetState extends State<AndroidAppsBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  late final Set<String> _selectedAppIds = Set<String>.from(
    widget.initialSelectedAppIds,
  );

  String get _searchQuery => _searchController.text.trim().toLowerCase();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() => setState(() {});

  void _toggle(String appId) {
    setState(() {
      if (_selectedAppIds.contains(appId)) {
        _selectedAppIds.remove(appId);
      } else {
        _selectedAppIds.add(appId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final height = MediaQuery.sizeOf(context).height * 0.85;

    return SizedBox(
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              l10n.modeBlockedAppsSectionTitle,
              style: textTheme.titleLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: l10n.modeBlockedAppsSearchLabel,
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<InstalledAppsBloc, InstalledAppsState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.modeAppsLoadFailedMessage,
                            style: textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          FilledButton.tonal(
                            onPressed: () {
                              context.read<InstalledAppsBloc>().add(
                                const InstalledAppsRequested(
                                  includeIcons: false,
                                  includeSystemApps: true,
                                ),
                              );
                            },
                            child: Text(l10n.retryButton),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final apps =
                    state.items
                        .whereType<AndroidAppInfo>()
                        .where(
                          (app) => _searchQuery.isEmpty
                              ? true
                              : app.name.toLowerCase().contains(_searchQuery) ||
                                    app.packageId.toLowerCase().contains(
                                      _searchQuery,
                                    ),
                        )
                        .toList(growable: false)
                      ..sort(
                        (left, right) => left.name.toLowerCase().compareTo(
                          right.name.toLowerCase(),
                        ),
                      );

                if (apps.isEmpty) {
                  return Center(
                    child: Text(
                      l10n.emptyStateMessage,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: apps.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final app = apps[index];
                    final isSelected = _selectedAppIds.contains(app.packageId);
                    return Material(
                      color: isSelected
                          ? colorScheme.primaryContainer
                          : colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _toggle(app.packageId),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      app.name,
                                      style: textTheme.titleMedium?.copyWith(
                                        color: isSelected
                                            ? colorScheme.onPrimaryContainer
                                            : colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      app.packageId,
                                      style: textTheme.bodySmall?.copyWith(
                                        color: isSelected
                                            ? colorScheme.onPrimaryContainer
                                            : colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                isSelected
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: isSelected
                                    ? colorScheme.primary
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.cancelButton),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(_selectedAppIds),
                    child: Text(l10n.okButton),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
