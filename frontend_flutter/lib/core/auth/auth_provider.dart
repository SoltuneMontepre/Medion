import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AuthStatus { unauthenticated, authenticated, loading }

class AuthState {
  const AuthState({
    this.status = AuthStatus.unauthenticated,
    this.userId,
    this.username,
    this.token,
  });

  final AuthStatus status;
  final String? userId;
  final String? username;
  final String? token;

  bool get isAuthenticated => status == AuthStatus.authenticated;
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  Future<void> login(String username, String password) async {
    state = const AuthState(status: AuthStatus.loading);
    // TODO: call Security.API via core/network
    state = AuthState(
      status: AuthStatus.authenticated,
      userId: '1',
      username: username,
      token: 'placeholder',
    );
  }

  void logout() {
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
