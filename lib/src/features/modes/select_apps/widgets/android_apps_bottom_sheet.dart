import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/app/root_scope.dart';
import 'package:pauza/src/core/common/extensions.dart';
import 'package:pauza/src/core/common_ui/pauza_error_widget.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/modes/select_apps/bloc/installed_apps_bloc.dart';
import 'package:pauza/src/features/modes/select_apps/widgets/selected_apps_scope.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class AndroidAppsBottomSheet extends StatelessWidget {
  const AndroidAppsBottomSheet({
    required this.initialSelectedAppIds,
    super.key,
  });

  final ISet<AppIdentifier> initialSelectedAppIds;

  static Future<Set<AppIdentifier>?> show(
    BuildContext context, {
    required ISet<AppIdentifier> initialSelectedAppIds,
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
    return SelectedAppsScope(
      notifier: SelectedAppsNotifier(initialSelected: initialSelectedAppIds),
      child: BlocProvider(
        create: (_) => InstalledAppsBloc(
          installedAppsRepository: RootScope.of(
            context,
          ).installedAppsRepository,
        )..add(const InstalledAppsRequested()),
        child: const AndroidAppsBottomSheetContent(),
      ),
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
          return PauzaErrorWidget(
            message: context.l10n.modeAppsLoadFailedMessage,
            onRetry: () => context.read<InstalledAppsBloc>().add(
              const InstalledAppsRequested(),
            ),
          );
        }

        return BottomSheetScaffold(
          title: Row(
            children: [
              Expanded(child: Text(context.l10n.selectAppsForPauzaTitle)),
              const _SelectedAppsCounter(),
            ],
          ),
          footer: const _FooterButton(),
          bodyPadding: const EdgeInsets.symmetric(vertical: PauzaSpacing.small),
          body: Column(
            spacing: PauzaSpacing.medium,
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
              SizedBox(
                height: 52,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: PauzaSpacing.medium,
                  ),
                  children:
                      [
                            PauzaFilterChip(
                              label: context.l10n.allAppsCategory,
                              isSelected: state.selectedCategoryKey == null,
                              onPressed: () {
                                context.read<InstalledAppsBloc>().add(
                                  const CategoryFilterChanged(
                                    categoryKey: null,
                                  ),
                                );
                              },
                            ),
                            ...state.availableCategoryKeys.map<Widget>(
                              (categoryKey) => PauzaFilterChip(
                                label: _localizeCategoryName(
                                  context,
                                  categoryKey,
                                ),
                                isSelected:
                                    state.selectedCategoryKey == categoryKey,
                                onPressed: () {
                                  context.read<InstalledAppsBloc>().add(
                                    CategoryFilterChanged(
                                      categoryKey: categoryKey,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ]
                          .interleaved(
                            const SizedBox(width: PauzaSpacing.regular),
                          )
                          .toList(),
                ),
              ),
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
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: PauzaSpacing.large),
                        itemBuilder: (context, index) {
                          final categoryKey = state.visibleGroupedApps.keys
                              .elementAt(index);
                          final categoryApps =
                              state.visibleGroupedApps[categoryKey]!;

                          return _CategorySection(
                            categoryKey: categoryKey,
                            categoryApps: categoryApps,
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

class _SelectedAppsCounter extends StatelessWidget {
  const _SelectedAppsCounter();

  @override
  Widget build(BuildContext context) {
    final scope = SelectedAppsScope.of(context);

    return AnimatedBuilder(
      animation: scope,
      builder: (context, _) {
        return DecoratedBox(
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
              context.l10n.appsSelectedCountLabel(scope.selectedCount),
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colorScheme.primary,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FooterButton extends StatelessWidget {
  const _FooterButton();

  @override
  Widget build(BuildContext context) {
    return PauzaFilledButton(
      onPressed: () {
        final scope = SelectedAppsScope.of(context, watch: false);
        Navigator.of(context).pop(scope.selectedAppIds.toSet());
      },
      title: Text(context.l10n.selectButton),
      width: double.infinity,
      size: PauzaButtonSize.large,
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.categoryKey,
    required this.categoryApps,
  });

  final String categoryKey;
  final IList<AndroidAppInfo> categoryApps;

  @override
  Widget build(BuildContext context) {
    final scope = SelectedAppsScope.of(context);
    final categoryAppIds = categoryApps.map((app) => app.packageId).toIList();

    return AnimatedBuilder(
      animation: scope,
      builder: (context, _) {
        final isFullySelected = scope.isCategoryFullySelected(categoryAppIds);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: PauzaSpacing.regular,
          children: [
            Row(
              spacing: 4,
              children: [
                Expanded(
                  child: Text(
                    categoryKey.toUpperCase(),
                    style: context.textTheme.titleMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.8,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    scope.toggleCategory(categoryAppIds, !isFullySelected);
                  },
                  child: Text(
                    isFullySelected
                        ? context.l10n.deselectAllButton
                        : context.l10n.selectAllButton,
                    style: context.textTheme.titleMedium?.copyWith(
                      color: context.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            ...categoryApps.map((app) => _AppTile(app: app)),
          ],
        );
      },
    );
  }
}

class _AppTile extends StatelessWidget {
  const _AppTile({required this.app});

  final AndroidAppInfo app;

  @override
  Widget build(BuildContext context) {
    final scope = SelectedAppsScope.of(context);

    return AnimatedBuilder(
      animation: scope,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.only(bottom: PauzaSpacing.medium),
          child: PauzaAppSelectionTile(
            onTap: () {
              scope.toggleApp(app.packageId);
            },
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(PauzaCornerRadius.medium),
              child: SizedBox(
                width: 52,
                height: 52,
                child: app.icon != null
                    ? Image.memory(app.icon!, fit: BoxFit.cover)
                    : DecoratedBox(
                        decoration: BoxDecoration(
                          color: context.colorScheme.surfaceContainer,
                        ),
                        child: Icon(
                          Icons.android,
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
              ),
            ),
            title: app.name,
            trailing: PauzaSelectionIndicator(
              isSelected: scope.isAppSelected(app.packageId),
            ),
          ),
        );
      },
    );
  }
}
