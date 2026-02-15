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
      create: (_) =>
          InstalledAppsBloc(
            installedAppsRepository: RootScope.of(
              context,
            ).installedAppsRepository,
          )..add(
            InstalledAppsRequested(
              includeSystemApps: true,
              initialSelectedAppIds: initialSelectedAppIds,
            ),
          ),
      child: const AndroidAppsBottomSheetContent(),
    );
  }
}

class AndroidAppsBottomSheetContent extends StatelessWidget {
  const AndroidAppsBottomSheetContent({super.key});

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

        return BottomSheetScaffold(
          showDivider: false,
          title: Row(
            children: [
              Expanded(child: Text(context.l10n.selectAppsForPauzaTitle)),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: context.colorScheme.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(PauzaCornerRadius.full),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: PauzaSpacing.medium,
                    vertical: PauzaSpacing.small,
                  ),
                  child: Text(
                    context.l10n.appsSelectedCountLabel(state.selectedCount),
                    style: context.textTheme.titleMedium?.copyWith(
                      color: context.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          footer: PauzaFilledButton(
            onPressed: () {
              Navigator.of(context).pop(state.selectedAppIds.toSet());
            },
            title: Text(context.l10n.selectButton),
            width: double.infinity,
            size: PauzaButtonSize.large,
            radius: PauzaCornerRadius.full,
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: PauzaSpacing.medium,
                ),
                child: PauzaTextFormField(
                  onChanged: (query) {
                    context.read<InstalledAppsBloc>().add(
                      SearchQueryChanged(searchQuery: query),
                    );
                  },
                  decoration: PauzaInputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: context.l10n.modeBlockedAppsSearchLabel,
                  ),
                ),
              ),
              const SizedBox(height: PauzaSpacing.medium),
              SizedBox(
                height: 52,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: PauzaSpacing.medium,
                  ),
                  children: [
                    PauzaFilterChip(
                      label: context.l10n.allAppsCategory,
                      isSelected: state.selectedCategoryKey == null,
                      onPressed: () {
                        context.read<InstalledAppsBloc>().add(
                          const CategoryFilterChanged(categoryKey: null),
                        );
                      },
                    ),
                    const SizedBox(width: PauzaSpacing.regular),
                    ...state.availableCategoryKeys.map(
                      (categoryKey) => Padding(
                        padding: const EdgeInsets.only(
                          right: PauzaSpacing.regular,
                        ),
                        child: PauzaFilterChip(
                          label: _localizeCategoryName(context, categoryKey),
                          isSelected: state.selectedCategoryKey == categoryKey,
                          onPressed: () {
                            context.read<InstalledAppsBloc>().add(
                              CategoryFilterChanged(categoryKey: categoryKey),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: PauzaSpacing.regular),
              Expanded(
                child: state.visibleGroupedApps.isEmpty
                    ? Center(
                        child: Text(
                          context.l10n.emptyStateMessage,
                          style: context.textTheme.bodyLarge?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: PauzaSpacing.medium,
                          vertical: PauzaSpacing.small,
                        ),
                        itemCount: state.visibleGroupedApps.length,
                        separatorBuilder: (_, separatorIndex) =>
                            const SizedBox(height: PauzaSpacing.large),
                        itemBuilder: (context, index) {
                          final categoryKey = state.visibleGroupedApps.keys
                              .elementAt(index);
                          final categoryApps =
                              state.visibleGroupedApps[categoryKey]!;
                          final isCategoryFullySelected = state
                              .isCategoryFullySelected(categoryKey);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _localizeCategoryName(
                                        context,
                                        categoryKey,
                                      ).toUpperCase(),
                                      style: context.textTheme.titleMedium
                                          ?.copyWith(
                                            color: context
                                                .colorScheme
                                                .onSurfaceVariant,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 1.8,
                                          ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      context.read<InstalledAppsBloc>().add(
                                        CategorySelectionToggled(
                                          categoryKey: categoryKey,
                                        ),
                                      );
                                    },
                                    child: Text(
                                      isCategoryFullySelected
                                          ? context.l10n.deselectAllButton
                                          : context.l10n.selectAllButton,
                                      style: context.textTheme.titleMedium
                                          ?.copyWith(
                                            color: context.colorScheme.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: PauzaSpacing.regular),
                              ...categoryApps.map(
                                (app) => Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: PauzaSpacing.medium,
                                  ),
                                  child: PauzaAppSelectionTile(
                                    onTap: () {
                                      context.read<InstalledAppsBloc>().add(
                                        AppSelectionToggled(
                                          appId: app.packageId,
                                        ),
                                      );
                                    },
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                        PauzaCornerRadius.medium,
                                      ),
                                      child: SizedBox(
                                        width: 52,
                                        height: 52,
                                        child: app.icon != null
                                            ? Image.memory(
                                                app.icon!,
                                                fit: BoxFit.cover,
                                              )
                                            : DecoratedBox(
                                                decoration: BoxDecoration(
                                                  color: context
                                                      .colorScheme
                                                      .surfaceContainer,
                                                ),
                                                child: Icon(
                                                  Icons.android,
                                                  color: context
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                              ),
                                      ),
                                    ),
                                    title: app.name,
                                    trailing: PauzaSelectionIndicator(
                                      isSelected: state.isAppSelected(
                                        app.packageId,
                                      ),
                                    ),
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

  String _localizeCategoryName(BuildContext context, String categoryKey) {
    if (categoryKey == 'Other') {
      return context.l10n.otherAppsCategory;
    }

    return categoryKey;
  }
}
