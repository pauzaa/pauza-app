import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:meta/meta.dart';

@immutable
final class InternetHealthState {
  const InternetHealthState({
    required this.isHealthy,
    required this.checkedAt,
    required this.lastError,
    required this.lastConnectivityResult,
  });

  factory InternetHealthState.initial() {
    return const InternetHealthState(isHealthy: false, checkedAt: null, lastError: null, lastConnectivityResult: null);
  }

  final bool isHealthy;
  final DateTime? checkedAt;
  final Object? lastError;
  final ConnectivityResult? lastConnectivityResult;

  InternetHealthState copyWith({
    bool? isHealthy,
    DateTime? checkedAt,
    Object? lastError = _sentinel,
    ConnectivityResult? lastConnectivityResult,
  }) {
    return InternetHealthState(
      isHealthy: isHealthy ?? this.isHealthy,
      checkedAt: checkedAt ?? this.checkedAt,
      lastError: identical(lastError, _sentinel) ? this.lastError : lastError,
      lastConnectivityResult: lastConnectivityResult ?? this.lastConnectivityResult,
    );
  }

  @override
  String toString() {
    return 'InternetHealthState('
        'isHealthy: $isHealthy, '
        'checkedAt: $checkedAt, '
        'lastError: $lastError, '
        'lastConnectivityResult: $lastConnectivityResult'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InternetHealthState &&
        other.isHealthy == isHealthy &&
        other.checkedAt == checkedAt &&
        _errorSignature(other.lastError) == _errorSignature(lastError) &&
        other.lastConnectivityResult == lastConnectivityResult;
  }

  @override
  int get hashCode => Object.hash(isHealthy, checkedAt, _errorSignature(lastError), lastConnectivityResult);

  static String? _errorSignature(Object? error) => error == null ? null : '${error.runtimeType}:${error.toString()}';
}

const Object _sentinel = Object();
