import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/auth_repository_impl.dart';

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

// Use 127.0.0.1 (not localhost) so Windows desktop uses IPv4 and matches backend; Chrome often works with localhost.
const _apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://127.0.0.1:9999',
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
    } on DioException catch (e, stack) {
      final fromBody = e.response?.data is Map
          ? (e.response!.data as Map)['message'] as String?
          : null;
      final status = e.response?.statusCode;
      final underlying = e.error?.toString();
      final parts = <String>[
        if (fromBody != null && fromBody.isNotEmpty) fromBody,
        if (e.message != null && e.message!.isNotEmpty) e.message!,
        if (underlying != null && underlying.isNotEmpty) underlying,
        if (status != null) 'HTTP $status',
        '(${e.type})',
      ];
      final message = parts.isNotEmpty ? parts.join(' · ') : 'Đăng nhập thất bại';
      state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: message.length > 280 ? '${message.substring(0, 280)}…' : message,
      );
      assert(() {
        // ignore: avoid_print
        print('Login DioException: ${e.type} message=${e.message} error=${e.error} response=${e.response?.statusCode}\n$stack');
        return true;
      }());
    } catch (e, stack) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: msg.length > 200 ? '${msg.substring(0, 200)}…' : msg,
      );
      assert(() {
        // ignore: avoid_print
        print('Login error: $e\n$stack');
        return true;
      }());
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
