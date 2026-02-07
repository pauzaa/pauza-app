part of 'modes_bloc.dart';

final class ModesListState extends Equatable {
  const ModesListState({
    this.isLoading = false,

    this.platform = PauzaPlatform.android,
    this.items = const <ModeSummary>[],
    this.selectedModeId,

    this.error,
  });

  final bool isLoading;
  final PauzaPlatform platform;
  final List<ModeSummary> items;
  final String? selectedModeId;
  final Object? error;

  bool get hasError => error != null;
  ModeSummary? get selectedMode =>
      items.firstWhereOrNull((summary) => summary.mode.id == selectedModeId);

  ModesListState loading() => copyWith(isLoading: true);

  ModesListState setError(Object error) =>
      copyWith(error: error, isLoading: false);

  ModesListState copyWith({
    bool? isLoading,
    PauzaPlatform? platform,
    List<ModeSummary>? items,
    String? selectedModeId,
    Object? error,
    bool clearError = false,
  }) {
    return ModesListState(
      isLoading: isLoading ?? this.isLoading,
      platform: platform ?? this.platform,
      items: items ?? this.items,
      selectedModeId: selectedModeId ?? this.selectedModeId,
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    isLoading,
    platform,
    items,
    selectedModeId,
    error,
  ];
}
