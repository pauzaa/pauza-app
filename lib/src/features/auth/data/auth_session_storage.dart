import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pauza/src/features/auth/common/model/auth_failure.dart';
import 'package:pauza/src/features/auth/common/model/session.dart';

abstract interface class AuthSessionStorage {
  Future<Session> readSession();

  Future<void> writeSession(Session session);

  Future<void> deleteSession();
}

final class SecureAuthSessionStorage implements AuthSessionStorage {
  SecureAuthSessionStorage({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const String _sessionKey = 'auth.session';

  final FlutterSecureStorage _secureStorage;

  @override
  Future<Session> readSession() async {
    try {
      final raw = await _secureStorage.read(key: _sessionKey);
      if (raw == null || raw.isEmpty) {
        return const Session.empty();
      }
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, Object?>) {
        throw const AuthStorageError();
      }
      return Session.fromJson(decoded);
    } on AuthError {
      rethrow;
    } on Object catch (e) {
      throw AuthStorageError(cause: e);
    }
  }

  @override
  Future<void> writeSession(Session session) async {
    try {
      final raw = jsonEncode(session.toJson());
      await _secureStorage.write(key: _sessionKey, value: raw);
    } on Object catch (e) {
      throw AuthStorageError(cause: e);
    }
  }

  @override
  Future<void> deleteSession() async {
    try {
      await _secureStorage.delete(key: _sessionKey);
    } on Object catch (e) {
      throw AuthStorageError(cause: e);
    }
  }
}
