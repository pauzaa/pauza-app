import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:pauza/src/core/connectivity/domain/internet_health_gate_notifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('InternetHealthGateNotifier', () {
    test('refresh marks healthy when connectivity exists and probe returns 204', () async {
      final client = FakeHttpClient(onSend: (_) async => _response(statusCode: 204));
      final connectivityController = StreamController<List<ConnectivityResult>>.broadcast();

      final gate = InternetHealthGateNotifier(
        probeUri: Uri.parse('https://example.com/health'),
        httpClient: client,
        checkConnectivity: () async => <ConnectivityResult>[ConnectivityResult.wifi],
        connectivityChanges: connectivityController.stream,
      );
      addTearDown(gate.dispose);
      addTearDown(connectivityController.close);

      await gate.refresh(force: true);

      expect(gate.isHealthy, isTrue);
      expect(gate.state.lastError, isNull);
      expect(gate.state.lastConnectivityResult, ConnectivityResult.wifi);
      expect(client.requestCount, 1);
    });

    test('refresh marks healthy on 401 and 404 responses', () async {
      final statuses = <int>[401, 404];

      for (final status in statuses) {
        final client = FakeHttpClient(onSend: (_) async => _response(statusCode: status));
        final connectivityController = StreamController<List<ConnectivityResult>>.broadcast();

        final gate = InternetHealthGateNotifier(
          probeUri: Uri.parse('https://example.com/health'),
          httpClient: client,
          checkConnectivity: () async => <ConnectivityResult>[ConnectivityResult.mobile],
          connectivityChanges: connectivityController.stream,
        );
        addTearDown(gate.dispose);
        addTearDown(connectivityController.close);

        await gate.refresh(force: true);
        expect(gate.isHealthy, isTrue);
      }
    });

    test('refresh marks healthy on 5xx responses (server error is not a connectivity issue)', () async {
      final statuses = <int>[500, 502, 503, 504];

      for (final status in statuses) {
        final client = FakeHttpClient(onSend: (_) async => _response(statusCode: status));
        final connectivityController = StreamController<List<ConnectivityResult>>.broadcast();

        final gate = InternetHealthGateNotifier(
          probeUri: Uri.parse('https://example.com/health'),
          httpClient: client,
          checkConnectivity: () async => <ConnectivityResult>[ConnectivityResult.wifi],
          connectivityChanges: connectivityController.stream,
        );
        addTearDown(gate.dispose);
        addTearDown(connectivityController.close);

        await gate.refresh(force: true);
        expect(gate.isHealthy, isTrue, reason: 'HTTP $status should be treated as healthy');
      }
    });

    test('refresh marks unhealthy when connectivity is none and probe is skipped', () async {
      final client = FakeHttpClient(onSend: (_) async => _response(statusCode: 204));
      final connectivityController = StreamController<List<ConnectivityResult>>.broadcast();

      final gate = InternetHealthGateNotifier(
        probeUri: Uri.parse('https://example.com/health'),
        httpClient: client,
        checkConnectivity: () async => <ConnectivityResult>[ConnectivityResult.none],
        connectivityChanges: connectivityController.stream,
      );
      addTearDown(gate.dispose);
      addTearDown(connectivityController.close);

      await gate.refresh(force: true);

      expect(gate.isHealthy, isFalse);
      expect(gate.state.lastConnectivityResult, ConnectivityResult.none);
      expect(gate.state.lastError, isNull);
      expect(client.requestCount, 0);
    });

    test('refresh marks unhealthy and captures error on timeout', () async {
      final client = FakeHttpClient(
        onSend: (_) async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return _response(statusCode: 204);
        },
      );
      final connectivityController = StreamController<List<ConnectivityResult>>.broadcast();

      final gate = InternetHealthGateNotifier(
        probeUri: Uri.parse('https://example.com/health'),
        httpClient: client,
        probeTimeout: const Duration(milliseconds: 10),
        checkConnectivity: () async => <ConnectivityResult>[ConnectivityResult.wifi],
        connectivityChanges: connectivityController.stream,
      );
      addTearDown(gate.dispose);
      addTearDown(connectivityController.close);

      await gate.refresh(force: true);

      expect(gate.isHealthy, isFalse);
      expect(gate.state.lastError, isA<TimeoutException>());
      expect(client.requestCount, 1);
    });

    test('notifies listeners only when effective state changes', () async {
      final client = FakeHttpClient(onSend: (_) async => _response(statusCode: 204));
      final connectivityController = StreamController<List<ConnectivityResult>>.broadcast();

      final gate = InternetHealthGateNotifier(
        probeUri: Uri.parse('https://example.com/health'),
        httpClient: client,
        checkConnectivity: () async => <ConnectivityResult>[ConnectivityResult.mobile],
        connectivityChanges: connectivityController.stream,
      );
      addTearDown(gate.dispose);
      addTearDown(connectivityController.close);

      var notifyCount = 0;
      gate.addListener(() {
        notifyCount += 1;
      });

      await gate.refresh(force: true);
      await gate.refresh(force: true);

      expect(notifyCount, 1);
    });

    test('refresh throttles repeated checks unless forced', () async {
      final client = FakeHttpClient(onSend: (_) async => _response(statusCode: 204));
      final connectivityController = StreamController<List<ConnectivityResult>>.broadcast();

      final gate = InternetHealthGateNotifier(
        probeUri: Uri.parse('https://example.com/health'),
        httpClient: client,
        minRefreshInterval: const Duration(milliseconds: 20),
        checkConnectivity: () async => <ConnectivityResult>[ConnectivityResult.wifi],
        connectivityChanges: connectivityController.stream,
      );
      addTearDown(gate.dispose);
      addTearDown(connectivityController.close);

      await gate.refresh(force: true);
      await gate.refresh();
      expect(client.requestCount, 1);

      await Future<void>.delayed(const Duration(milliseconds: 25));
      await gate.refresh();
      expect(client.requestCount, 2);
    });

    test('lifecycle resume triggers refresh', () async {
      final client = FakeHttpClient(onSend: (_) async => _response(statusCode: 204));
      final connectivityController = StreamController<List<ConnectivityResult>>.broadcast();

      final gate = InternetHealthGateNotifier(
        probeUri: Uri.parse('https://example.com/health'),
        httpClient: client,
        checkConnectivity: () async => <ConnectivityResult>[ConnectivityResult.wifi],
        connectivityChanges: connectivityController.stream,
      );
      addTearDown(gate.dispose);
      addTearDown(connectivityController.close);

      gate.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await Future<void>.delayed(Duration.zero);

      expect(client.requestCount, 1);
    });

    test('connectivity change stream triggers refresh', () async {
      final client = FakeHttpClient(onSend: (_) async => _response(statusCode: 204));
      final connectivityController = StreamController<List<ConnectivityResult>>.broadcast();

      final gate = InternetHealthGateNotifier(
        probeUri: Uri.parse('https://example.com/health'),
        httpClient: client,
        checkConnectivity: () async => throw StateError('stream value must be used'),
        connectivityChanges: connectivityController.stream,
      );
      addTearDown(gate.dispose);
      addTearDown(connectivityController.close);

      connectivityController.add(<ConnectivityResult>[ConnectivityResult.mobile]);
      await Future<void>.delayed(Duration.zero);

      expect(client.requestCount, 1);
      expect(gate.state.lastConnectivityResult, ConnectivityResult.mobile);
    });
  });
}

final class FakeHttpClient extends BaseClient {
  FakeHttpClient({required this.onSend});

  final Future<StreamedResponse> Function(BaseRequest request) onSend;
  int requestCount = 0;

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    requestCount += 1;
    return onSend(request);
  }
}

StreamedResponse _response({required int statusCode}) {
  return StreamedResponse(const Stream<List<int>>.empty(), statusCode);
}
