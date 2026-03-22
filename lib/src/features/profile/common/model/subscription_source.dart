enum SubscriptionSource {
  revenuecat('revenuecat'),
  adminOverride('admin_override');

  const SubscriptionSource(this.jsonValue);

  final String jsonValue;

  static SubscriptionSource? fromJson(String? value) {
    if (value == null) return null;
    for (final source in values) {
      if (source.jsonValue == value) return source;
    }
    return null;
  }
}
