import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'package:pauza/src/core/connectivity/domain/internet_health_gate.dart';
import 'package:pauza/src/core/connectivity/model/internet_health_state.dart';

final class InternetHealthGateNotifier extends ChangeNotifier
    with WidgetsBindingObserver
    implements InternetHealthGate {
  InternetHealthGateNotifier({
    required Uri probeUri,
    Connectivity? connectivity,
    Client? httpClient,
    Duration minRefreshInterval = const Duration(seconds: 5),
    Duration probeTimeout = const Duration(seconds: 3),
    Future<List<ConnectivityResult>> Function()? checkConnectivity,
    Stream<List<ConnectivityResult>>? connectivityChanges,
  }) : this._(
         probeUri: probeUri,
         connectivity: connectivity ?? Connectivity(),
         httpClient: httpClient,
         minRefreshInterval: minRefreshInterval,
         probeTimeout: probeTimeout,
         checkConnectivity: checkConnectivity,
         connectivityChanges: connectivityChanges,
       );

  InternetHealthGateNotifier._({
    required Uri probeUri,
    required Connectivity connectivity,
    Client? httpClient,
    Duration minRefreshInterval = const Duration(seconds: 5),
    Duration probeTimeout = const Duration(seconds: 3),
    Future<List<ConnectivityResult>> Function()? checkConnectivity,
    Stream<List<ConnectivityResult>>? connectivityChanges,
  }) : _probeUri = probeUri,
       _minRefreshInterval = minRefreshInterval,
       _probeTimeout = probeTimeout,
       _httpClient = httpClient ?? Client(),
       _ownsHttpClient = httpClient == null,
       _checkConnectivity = checkConnectivity ?? (() => connectivity.checkConnectivity()),
       _connectivityChanges = connectivityChanges ?? connectivity.onConnectivityChanged {
    WidgetsBinding.instance.addObserver(this);
    _connectivitySubscription = _connectivityChanges.listen(_onConnectivityChanged);
  }

  final Uri _probeUri;
  final Duration _minRefreshInterval;
  final Duration _probeTimeout;
  final Client _httpClient;
  final bool _ownsHttpClient;
  final Future<List<ConnectivityResult>> Function() _checkConnectivity;
  final Stream<List<ConnectivityResult>> _connectivityChanges;

  InternetHealthState _state = InternetHealthState.initial();
  DateTime? _lastRefreshAt;
  Future<void>? _inFlightRefresh;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  InternetHealthState get state => _state;

  @override
  bool get isHealthy => _state.isHealthy;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(refresh());
    }
  }

  @override
  Future<void> refresh({bool force = false}) async {
    return _scheduleRefresh(force: force);
  }

  Future<void> _scheduleRefresh({bool force = false, List<ConnectivityResult>? connectivityResults}) async {
    final refreshInProgress = _inFlightRefresh;
    if (refreshInProgress != null) {
      return refreshInProgress;
    }

    if (!force) {
      if (_lastRefreshAt case final lastRefreshAt?
          when DateTime.now().difference(lastRefreshAt) < _minRefreshInterval) {
        return;
      }
    }

    final refreshFuture = _refreshInternal(connectivityResults: connectivityResults);
    _inFlightRefresh = refreshFuture;

    try {
      await refreshFuture;
    } finally {
      if (identical(_inFlightRefresh, refreshFuture)) {
        _inFlightRefresh = null;
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_connectivitySubscription?.cancel());
    if (_ownsHttpClient) {
      _httpClient.close();
    }
    super.dispose();
  }

  void _onConnectivityChanged(List<ConnectivityResult> connectivityResults) {
    unawaited(_scheduleRefresh(connectivityResults: connectivityResults));
  }

  Future<void> _refreshInternal({List<ConnectivityResult>? connectivityResults}) async {
    final checkedAt = DateTime.now();
    final connectivityResult = _pickConnectivityResult(connectivityResults ?? await _checkConnectivity());

    if (connectivityResult == ConnectivityResult.none) {
      _applyState(
        InternetHealthState(
          isHealthy: false,
          checkedAt: checkedAt,
          lastError: null,
          lastConnectivityResult: connectivityResult,
        ),
      );
      _lastRefreshAt = checkedAt;
      return;
    }

    try {
      await _httpClient.get(_probeUri).timeout(_probeTimeout);
      _applyState(
        InternetHealthState(
          isHealthy: true,
          checkedAt: checkedAt,
          lastError: null,
          lastConnectivityResult: connectivityResult,
        ),
      );
    } on Object catch (error) {
      _applyState(
        InternetHealthState(
          isHealthy: false,
          checkedAt: checkedAt,
          lastError: error,
          lastConnectivityResult: connectivityResult,
        ),
      );
    } finally {
      _lastRefreshAt = checkedAt;
    }
  }

  ConnectivityResult _pickConnectivityResult(List<ConnectivityResult> rawResults) {
    for (final connectivityResult in rawResults) {
      if (connectivityResult != ConnectivityResult.none) {
        return connectivityResult;
      }
    }
    return ConnectivityResult.none;
  }

  void _applyState(InternetHealthState nextState) {
    final shouldNotify =
        _state.isHealthy != nextState.isHealthy ||
        _state.lastConnectivityResult != nextState.lastConnectivityResult ||
        _errorSignature(_state.lastError) != _errorSignature(nextState.lastError);

    _state = nextState;

    if (!shouldNotify) {
      return;
    }

    notifyListeners();
  }

  String? _errorSignature(Object? error) => error == null ? null : '${error.runtimeType}:${error.toString()}';
}
