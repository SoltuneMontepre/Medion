/// Placeholder for auth. Implement login/token storage when needed.
abstract class AuthRepository {
  Future<bool> isAuthenticated();
  Future<void> logout();
}
