import 'package:pauza/src/features/restriction_lifecycle/sync/background/restriction_lifecycle_background_worker.dart';
import 'package:workmanager/workmanager.dart';

abstract interface class RestrictionLifecycleBackgroundScheduler {
  Future<void> initializeAndScheduleDailySync();
}

abstract interface class WorkmanagerClient {
  Future<void> initialize(Function callbackDispatcher);

  Future<void> registerPeriodicTask(
    String uniqueName,
    String taskName, {
    required Duration frequency,
    Duration? initialDelay,
    ExistingPeriodicWorkPolicy? existingWorkPolicy,
    BackoffPolicy? backoffPolicy,
    Duration? backoffPolicyDelay,
  });
}

final class WorkmanagerClientImpl implements WorkmanagerClient {
  const WorkmanagerClientImpl();

  @override
  Future<void> initialize(Function callbackDispatcher) {
    return Workmanager().initialize(callbackDispatcher);
  }

  @override
  Future<void> registerPeriodicTask(
    String uniqueName,
    String taskName, {
    required Duration frequency,
    Duration? initialDelay,
    ExistingPeriodicWorkPolicy? existingWorkPolicy,
    BackoffPolicy? backoffPolicy,
    Duration? backoffPolicyDelay,
  }) {
    return Workmanager().registerPeriodicTask(
      uniqueName,
      taskName,
      frequency: frequency,
      initialDelay: initialDelay,
      existingWorkPolicy: existingWorkPolicy,
      backoffPolicy: backoffPolicy,
      backoffPolicyDelay: backoffPolicyDelay,
    );
  }
}

final class WorkmanagerRestrictionLifecycleBackgroundScheduler implements RestrictionLifecycleBackgroundScheduler {
  WorkmanagerRestrictionLifecycleBackgroundScheduler({
    WorkmanagerClient? workmanagerClient,
    DateTime Function()? nowLocal,
  }) : _workmanagerClient = workmanagerClient ?? const WorkmanagerClientImpl(),
       _nowLocal = nowLocal ?? DateTime.now;

  final WorkmanagerClient _workmanagerClient;
  final DateTime Function() _nowLocal;

  static const Duration _dailyFrequency = Duration(hours: 24);
  static const Duration _retryBackoffDelay = Duration(minutes: 30);

  @override
  Future<void> initializeAndScheduleDailySync() async {
    await _workmanagerClient.initialize(restrictionLifecycleBackgroundCallbackDispatcher);

    final now = _nowLocal();
    final initialDelay = _computeInitialDelayToNextMidnight(nowLocal: now);

    await _workmanagerClient.registerPeriodicTask(
      restrictionLifecycleBackgroundTaskUniqueName,
      restrictionLifecycleBackgroundTaskIdentifier,
      frequency: _dailyFrequency,
      initialDelay: initialDelay,
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
      backoffPolicy: BackoffPolicy.linear,
      backoffPolicyDelay: _retryBackoffDelay,
    );
  }

  static Duration _computeInitialDelayToNextMidnight({required DateTime nowLocal}) {
    final nextMidnight = DateTime(nowLocal.year, nowLocal.month, nowLocal.day + 1);
    return nextMidnight.difference(nowLocal);
  }
}
