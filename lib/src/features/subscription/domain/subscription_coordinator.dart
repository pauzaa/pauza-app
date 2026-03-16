import 'dart:async';
import 'dart:developer';

import 'package:pauza/src/features/auth/data/auth_repository.dart';
import 'package:pauza/src/features/profile/data/user_profile_repository.dart';
import 'package:pauza/src/features/subscription/data/subscription_repository.dart';

/// Coordinates RevenueCat SDK lifecycle with the auth session.
///
/// Mirrors [DeviceTokenCoordinator] pattern: listens to [AuthRepository.sessionStream],
/// initialises RevenueCat on sign-in (using the real user ID), and logs out on sign-out.
final class SubscriptionCoordinator {
  SubscriptionCoordinator({
    required AuthRepository authRepository,
    required UserProfileRepository userProfileRepository,
    required SubscriptionRepository subscriptionRepository,
    required String revenueCatApiKey,
  }) : _authRepository = authRepository,
       _userProfileRepository = userProfileRepository,
       _subscriptionRepository = subscriptionRepository,
       _revenueCatApiKey = revenueCatApiKey;

  final AuthRepository _authRepository;
  final UserProfileRepository _userProfileRepository;
  final SubscriptionRepository _subscriptionRepository;
  final String _revenueCatApiKey;

  bool _isAttached = false;
  StreamSubscription<void>? _sessionSubscription;
  StreamSubscription<void>? _profileSubscription;

  void attach() {
    if (_isAttached) return;

    _sessionSubscription = _authRepository.sessionStream.listen((_) => _onSessionChanged());
    _isAttached = true;
  }

  void detach() {
    if (!_isAttached) return;

    _sessionSubscription?.cancel();
    _sessionSubscription = null;
    _cancelProfileSubscription();
    _isAttached = false;
  }

  // ---------------------------------------------------------------------------

  void _onSessionChanged() {
    final isAuthenticated = _authRepository.currentSession.isAuthenticated;

    if (isAuthenticated) {
      unawaited(_initializeWithUserId());
    } else {
      _cancelProfileSubscription();
      unawaited(_subscriptionRepository.logOut());
    }
  }

  Future<void> _initializeWithUserId() async {
    // Subscribe to profile changes first to avoid a race where a profile
    // arrives between the cache read returning null and the subscription
    // being set up.
    _cancelProfileSubscription();
    _profileSubscription = _userProfileRepository.watchProfileChanges().listen((user) async {
      if (!_isAttached) return;
      if (user.id.isNotEmpty) {
        _cancelProfileSubscription();
        try {
          await _subscriptionRepository.initialize(apiKey: _revenueCatApiKey, appUserId: user.id);
        } on Object catch (e) {
          log('SubscriptionCoordinator: deferred init failed: $e', name: 'subscription');
        }
      }
    });

    try {
      final cached = await _userProfileRepository.readCachedProfile();
      if (!_isAttached) return;
      if (cached != null && cached.data.id.isNotEmpty) {
        _cancelProfileSubscription();
        await _subscriptionRepository.initialize(apiKey: _revenueCatApiKey, appUserId: cached.data.id);
      }
    } on Object catch (e) {
      log('SubscriptionCoordinator: cached profile read failed: $e', name: 'subscription');
    }
  }

  void _cancelProfileSubscription() {
    _profileSubscription?.cancel();
    _profileSubscription = null;
  }
}
