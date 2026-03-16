import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:pauza/src/features/subscription/data/purchases_data_source.dart';
import 'package:pauza/src/features/subscription/model/subscription_failure.dart';

abstract interface class SubscriptionRepository {
  Future<void> initialize({required String apiKey, required String appUserId});

  Future<Offering?> getOffering();

  Future<void> purchase(Package package);

  Future<void> restorePurchases();

  Future<void> logOut();

  void dispose();
}

final class SubscriptionRepositoryImpl implements SubscriptionRepository {
  SubscriptionRepositoryImpl({required PurchasesDataSource dataSource, required String entitlementId})
    : _dataSource = dataSource,
      _entitlementId = entitlementId;

  final PurchasesDataSource _dataSource;
  // Reserved for future entitlement checks.
  // ignore: unused_field
  final String _entitlementId;

  @override
  Future<void> initialize({required String apiKey, required String appUserId}) async {
    try {
      await _dataSource.configure(apiKey: apiKey, appUserId: appUserId);
      log('SubscriptionRepository: configured for user $appUserId', name: 'subscription');
    } on Object catch (e) {
      log('SubscriptionRepository: configure failed: $e', name: 'subscription');
      throw SubscriptionUnknownError(e);
    }
  }

  @override
  Future<Offering?> getOffering() async {
    if (!_dataSource.isConfigured) throw const SubscriptionNotConfiguredError();

    try {
      final offerings = await _dataSource.getOfferings();
      return offerings.current;
    } on Object catch (e) {
      log('SubscriptionRepository: getOffering failed: $e', name: 'subscription');
      throw SubscriptionUnknownError(e);
    }
  }

  @override
  Future<void> purchase(Package package) async {
    if (!_dataSource.isConfigured) throw const SubscriptionNotConfiguredError();

    try {
      await _dataSource.purchasePackage(package);
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        throw const SubscriptionPurchaseCancelledError();
      }
      if (errorCode == PurchasesErrorCode.networkError) {
        throw const SubscriptionNetworkError();
      }
      throw SubscriptionUnknownError(e);
    } on Object catch (e) {
      throw SubscriptionUnknownError(e);
    }
  }

  @override
  Future<void> restorePurchases() async {
    if (!_dataSource.isConfigured) throw const SubscriptionNotConfiguredError();

    try {
      await _dataSource.restorePurchases();
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.networkError) {
        throw const SubscriptionNetworkError();
      }
      throw SubscriptionUnknownError(e);
    } on Object catch (e) {
      throw SubscriptionUnknownError(e);
    }
  }

  @override
  Future<void> logOut() async {
    try {
      await _dataSource.logOut();
      log('SubscriptionRepository: logged out', name: 'subscription');
    } on Object catch (e) {
      log('SubscriptionRepository: logOut failed: $e', name: 'subscription');
    }
  }

  @override
  void dispose() {
    // No-op; RevenueCat SDK lifecycle is managed by the coordinator.
  }
}
