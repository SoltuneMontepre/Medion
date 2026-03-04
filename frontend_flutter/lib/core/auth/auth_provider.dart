import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/auth_repository_impl.dart';
import 'dto/auth_dto.dart';

enum AuthStatus { unauthenticated, authenticated, loading }

class AuthState {
  const AuthState({
    this.status = AuthStatus.unauthenticated,
    this.userId,
    this.username,
    this.token,
    this.errorMessage,
  });

  final AuthStatus status;
  final String? userId;
  final String? username;
  final String? token;
  final String? errorMessage;

  bool get isAuthenticated => status == AuthStatus.authenticated;
}

final authRepositoryProvider = Provider<AuthRepositoryImpl>((ref) {
  return AuthRepositoryImpl(baseUrl: _apiBaseUrl);
});

const _apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:9999',
);

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repo) : super(const AuthState());
  final AuthRepositoryImpl _repo;
  bool _hasRestored = false;

  Future<void> restoreSession() async {
    if (_hasRestored) return;
    _hasRestored = true;
    state = const AuthState(status: AuthStatus.loading);
    try {
      final token = await _repo.getStoredAccessToken();
      if (token != null && token.isNotEmpty) {
        state = AuthState(status: AuthStatus.authenticated, token: token);
      } else {
        state = const AuthState();
      }
    } catch (_) {
      state = const AuthState();
    }
  }

  Future<void> login(String email, String password) async {
    state = const AuthState(status: AuthStatus.loading, errorMessage: null);
    try {
      final data = await _repo.login(email, password);
      state = AuthState(
        status: AuthStatus.authenticated,
        userId: data.user.id,
        username: data.user.username,
        token: data.accessToken,
      );
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? (e.response!.data as Map)['message'] as String?
          : null;
      state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: message ?? e.message ?? 'Đăng nhập thất bại',
      );
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void clearError() {
    if (state.errorMessage != null) {
      state = AuthState(
        status: state.status,
        userId: state.userId,
        username: state.username,
        token: state.token,
      );
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});
