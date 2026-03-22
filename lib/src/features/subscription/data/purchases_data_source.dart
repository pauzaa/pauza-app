import 'dart:async';

import 'package:purchases_flutter/purchases_flutter.dart';

abstract interface class PurchasesDataSource {
  bool get isConfigured;

  Stream<CustomerInfo> get customerInfoUpdates;

  Future<void> configure({required String apiKey, required String appUserId});

  Future<void> logIn(String appUserId);

  Future<void> logOut();

  Future<Offerings> getOfferings();

  Future<CustomerInfo> purchasePackage(Package package);

  Future<CustomerInfo> restorePurchases();

  Future<String?> getManagementUrl();

  void dispose();
}

final class PurchasesDataSourceImpl implements PurchasesDataSource {
  bool _isConfigured = false;
  final StreamController<CustomerInfo> _customerInfoController = StreamController<CustomerInfo>.broadcast();
  CustomerInfoUpdateListener? _listener;

  @override
  bool get isConfigured => _isConfigured;

  @override
  Stream<CustomerInfo> get customerInfoUpdates => _customerInfoController.stream;

  @override
  Future<void> configure({required String apiKey, required String appUserId}) async {
    if (_isConfigured) return;

    final configuration = PurchasesConfiguration(apiKey)..appUserID = appUserId;
    await Purchases.configure(configuration);
    _isConfigured = true;

    _listener = (customerInfo) {
      if (!_customerInfoController.isClosed) {
        _customerInfoController.add(customerInfo);
      }
    };
    Purchases.addCustomerInfoUpdateListener(_listener!);
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

  @override
  Future<String?> getManagementUrl() async {
    final customerInfo = await Purchases.getCustomerInfo();
    return customerInfo.managementURL;
  }

  @override
  void dispose() {
    if (_listener != null) {
      Purchases.removeCustomerInfoUpdateListener(_listener!);
      _listener = null;
    }
    _customerInfoController.close();
  }
}
