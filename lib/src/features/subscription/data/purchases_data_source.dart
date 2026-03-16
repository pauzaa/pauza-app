import 'package:purchases_flutter/purchases_flutter.dart';

abstract interface class PurchasesDataSource {
  bool get isConfigured;

  Future<void> configure({required String apiKey, required String appUserId});

  Future<void> logIn(String appUserId);

  Future<void> logOut();

  Future<Offerings> getOfferings();

  Future<CustomerInfo> purchasePackage(Package package);

  Future<CustomerInfo> restorePurchases();
}

final class PurchasesDataSourceImpl implements PurchasesDataSource {
  bool _isConfigured = false;

  @override
  bool get isConfigured => _isConfigured;

  @override
  Future<void> configure({required String apiKey, required String appUserId}) async {
    if (_isConfigured) return;

    final configuration = PurchasesConfiguration(apiKey)..appUserID = appUserId;
    await Purchases.configure(configuration);
    _isConfigured = true;
  }

  @override
  Future<void> logIn(String appUserId) async {
    await Purchases.logIn(appUserId);
  }

  @override
  Future<void> logOut() async {
    if (!_isConfigured) return;
    await Purchases.logOut();
  }

  @override
  Future<Offerings> getOfferings() async {
    return Purchases.getOfferings();
  }

  @override
  Future<CustomerInfo> purchasePackage(Package package) async {
    return Purchases.purchasePackage(package);
  }

  @override
  Future<CustomerInfo> restorePurchases() async {
    return Purchases.restorePurchases();
  }
}
