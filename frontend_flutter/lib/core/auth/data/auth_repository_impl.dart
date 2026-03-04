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
  })  : _dio = Dio(BaseOptions(baseUrl: baseUrl)),
        _storage = secureStorage ?? const FlutterSecureStorage();

  final Dio _dio;
  final FlutterSecureStorage _storage;

  Future<AuthData> login(String email, String password) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/login',
      data: LoginRequest(email: email.trim(), password: password).toJson(),
    );
    final envelope = AuthEnvelope.fromJson(response.data!);
    await _storage.write(key: _storageKeyAccessToken, value: envelope.data.accessToken);
    return envelope.data;
  }

  Future<String?> getStoredAccessToken() async {
    return _storage.read(key: _storageKeyAccessToken);
  }

  Future<void> logout() async {
    await _storage.delete(key: _storageKeyAccessToken);
  }
}
