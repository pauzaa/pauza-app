sealed class SubscriptionError {
  const SubscriptionError();
}

final class SubscriptionPurchaseCancelledError extends SubscriptionError {
  const SubscriptionPurchaseCancelledError();
}

final class SubscriptionNetworkError extends SubscriptionError {
  const SubscriptionNetworkError();
}

final class SubscriptionNotConfiguredError extends SubscriptionError {
  const SubscriptionNotConfiguredError();
}

final class SubscriptionUnknownError extends SubscriptionError {
  const SubscriptionUnknownError([this.cause]);

  final Object? cause;
}
