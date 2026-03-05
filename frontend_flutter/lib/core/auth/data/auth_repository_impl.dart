import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../dto/auth_dto.dart';

const _storageKeyAccessToken = 'mes_medion_access_token';

/// Persists access token and calls backend /api/v1/login.
/// Uses its own Dio (no auth header) to avoid circular dependency with apiClientProvider.
class AuthRepositoryImpl {
  AuthRepositoryImpl({
    required String baseUrl,
    FlutterSecureStorage? secureStorage,
  })  : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        )),
        _storage = secureStorage ?? const FlutterSecureStorage();

  final Dio _dio;
  final FlutterSecureStorage _storage;

  Future<AuthData> login(String email, String password) async {
    final response = await _dio.post<dynamic>(
      '/api/v1/login',
      data: LoginRequest(email: email.trim(), password: password).toJson(),
    );
    final raw = response.data;
    if (raw == null) {
      throw Exception('Login response body is null');
    }
    final Map<String, dynamic> body = raw is Map<String, dynamic>
        ? raw
        : raw is String
            ? (jsonDecode(raw) as Map<String, dynamic>)
            : throw Exception('Unexpected response type: ${raw.runtimeType}');
    final envelope = AuthEnvelope.fromJson(body);
    // Best-effort persist token; e.g. FlutterSecureStorage can fail on Windows (file lock/corruption).
    try {
      await _storage.write(key: _storageKeyAccessToken, value: envelope.data.accessToken);
    } catch (_) {
      // Still return auth data so login succeeds this session; token may not persist across restarts.
    }
    return envelope.data;
  }

  Future<String?> getStoredAccessToken() async {
    return _storage.read(key: _storageKeyAccessToken);
  }

  Future<void> logout() async {
    await _storage.delete(key: _storageKeyAccessToken);
  }
}
