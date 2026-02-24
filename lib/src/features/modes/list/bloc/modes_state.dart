part of 'modes_bloc.dart';

final class ModesListState extends Equatable {
  const ModesListState({
    this.isLoading = false,

    this.platform = PauzaPlatform.android,
    this.items = const <Mode>[],
    this.selectedModeId,

    this.error,
  });

  final bool isLoading;
  final PauzaPlatform platform;
  final List<Mode> items;
  final String? selectedModeId;
  final Object? error;

  bool get hasError => error != null;
  Mode? get selectedMode => items.firstWhereOrNull((summary) => summary.id == selectedModeId);

  ModesListState loading() => copyWith(isLoading: true);

  ModesListState setError(Object error) => copyWith(error: error, isLoading: false);

  ModesListState copyWith({
    bool? isLoading,
    PauzaPlatform? platform,
    List<Mode>? items,
    String? selectedModeId,
    Object? error,
  }) {
    return ModesListState(
      isLoading: isLoading ?? this.isLoading,
      platform: platform ?? this.platform,
      items: items ?? this.items,
      selectedModeId: selectedModeId ?? this.selectedModeId,
      error: error,
    );
  }

  @override
  List<Object?> get props => <Object?>[isLoading, platform, items, selectedModeId, error];
}
