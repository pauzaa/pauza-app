import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:pauza/src/features/profile/common/bloc/current_user_bloc.dart';
import 'package:pauza/src/features/subscription/data/subscription_repository.dart';
import 'package:pauza/src/features/subscription/model/subscription_failure.dart';

part 'paywall_event.dart';
part 'paywall_state.dart';

final class PaywallBloc extends Bloc<PaywallEvent, PaywallState> {
  PaywallBloc({required SubscriptionRepository subscriptionRepository, required CurrentUserBloc currentUserBloc})
    : _subscriptionRepository = subscriptionRepository,
      _currentUserBloc = currentUserBloc,
      super(const PaywallState()) {
    on<PaywallStarted>(_onStarted);
    on<PaywallPurchaseRequested>(_onPurchaseRequested);
    on<PaywallRestoreRequested>(_onRestoreRequested);
  }

  final SubscriptionRepository _subscriptionRepository;
  final CurrentUserBloc _currentUserBloc;

  Future<void> _onStarted(PaywallStarted event, Emitter<PaywallState> emit) async {
    emit(state.copyWith(isLoadingOfferings: true, clearError: true));

    try {
      final offering = await _subscriptionRepository.getOffering();
      final packages = offering?.availablePackages ?? <Package>[];
      emit(state.copyWith(packages: packages, isLoadingOfferings: false));
    } on SubscriptionError catch (e) {
      emit(state.copyWith(isLoadingOfferings: false, error: e));
    } on Object catch (e) {
      emit(state.copyWith(isLoadingOfferings: false, error: SubscriptionUnknownError(e)));
    }
  }

  Future<void> _onPurchaseRequested(PaywallPurchaseRequested event, Emitter<PaywallState> emit) async {
    emit(state.copyWith(isPurchasing: true, clearError: true, clearPurchaseSuccess: true));

    try {
      await _subscriptionRepository.purchase(event.package);
      _currentUserBloc.refresh(forceRemote: true);
      emit(state.copyWith(isPurchasing: false, purchaseSuccess: true));
    } on SubscriptionPurchaseCancelledError {
      emit(state.copyWith(isPurchasing: false));
    } on SubscriptionError catch (e) {
      emit(state.copyWith(isPurchasing: false, error: e));
    } on Object catch (e) {
      emit(state.copyWith(isPurchasing: false, error: SubscriptionUnknownError(e)));
    }
  }

  Future<void> _onRestoreRequested(PaywallRestoreRequested event, Emitter<PaywallState> emit) async {
    emit(state.copyWith(isPurchasing: true, clearError: true, clearPurchaseSuccess: true));

    try {
      await _subscriptionRepository.restorePurchases();
      _currentUserBloc.refresh(forceRemote: true);
      emit(state.copyWith(isPurchasing: false, purchaseSuccess: true));
    } on SubscriptionError catch (e) {
      emit(state.copyWith(isPurchasing: false, error: e));
    } on Object catch (e) {
      emit(state.copyWith(isPurchasing: false, error: SubscriptionUnknownError(e)));
    }
  }
}
