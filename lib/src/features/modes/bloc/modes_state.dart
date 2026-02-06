part of 'modes_bloc.dart';

enum ModesStatus { initial, loading, ready, failure }

final class ModesState extends Equatable {
  const ModesState({
    this.status = ModesStatus.initial,
    this.platform = PauzaPlatform.android,
    this.items = const <ModeSummary>[],
    this.selectedModeId,
    this.errorMessage,
  });

  final ModesStatus status;
  final PauzaPlatform platform;
  final List<ModeSummary> items;
  final String? selectedModeId;
  final String? errorMessage;

  ModeSummary? get selectedMode {
    if (selectedModeId case final String id) {
      return items.firstWhereOrNull((summary) => summary.mode.id == id);
    }
    return null;
  }

  ModesState copyWith({
    ModesStatus? status,
    PauzaPlatform? platform,
    List<ModeSummary>? items,
    String? selectedModeId,
    bool clearSelectedModeId = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ModesState(
      status: status ?? this.status,
      platform: platform ?? this.platform,
      items: items ?? this.items,
      selectedModeId: clearSelectedModeId
          ? null
          : (selectedModeId ?? this.selectedModeId),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    platform,
    items,
    selectedModeId,
    errorMessage,
  ];
}
