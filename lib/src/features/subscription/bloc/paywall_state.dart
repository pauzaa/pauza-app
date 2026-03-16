part of 'paywall_bloc.dart';

final class PaywallState {
  const PaywallState({
    this.packages = const <Package>[],
    this.isPurchasing = false,
    this.isLoadingOfferings = false,
    this.purchaseSuccess = false,
    this.error,
  });

  final List<Package> packages;
  final bool isPurchasing;
  final bool isLoadingOfferings;
  final bool purchaseSuccess;
  final SubscriptionError? error;

  PaywallState copyWith({
    List<Package>? packages,
    bool? isPurchasing,
    bool? isLoadingOfferings,
    bool? purchaseSuccess,
    SubscriptionError? error,
    bool clearError = false,
    bool clearPurchaseSuccess = false,
  }) {
    return PaywallState(
      packages: packages ?? this.packages,
      isPurchasing: isPurchasing ?? this.isPurchasing,
      isLoadingOfferings: isLoadingOfferings ?? this.isLoadingOfferings,
      purchaseSuccess: clearPurchaseSuccess ? false : purchaseSuccess ?? this.purchaseSuccess,
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PaywallState) return false;
    if (packages.length != other.packages.length) return false;
    for (var i = 0; i < packages.length; i++) {
      if (packages[i].identifier != other.packages[i].identifier) return false;
    }
    return isPurchasing == other.isPurchasing &&
        isLoadingOfferings == other.isLoadingOfferings &&
        purchaseSuccess == other.purchaseSuccess &&
        error == other.error;
  }

  @override
  int get hashCode => Object.hash(
    Object.hashAll(packages.map((p) => p.identifier)),
    isPurchasing,
    isLoadingOfferings,
    purchaseSuccess,
    error,
  );
}
