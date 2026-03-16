part of 'paywall_bloc.dart';

sealed class PaywallEvent {
  const PaywallEvent();
}

final class PaywallStarted extends PaywallEvent {
  const PaywallStarted();
}

final class PaywallPurchaseRequested extends PaywallEvent {
  const PaywallPurchaseRequested({required this.package});

  final Package package;
}

final class PaywallRestoreRequested extends PaywallEvent {
  const PaywallRestoreRequested();
}
