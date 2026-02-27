/// Domain entity. No Flutter, no JSON.
/// Corresponds to Security.API backend (e.g. transaction pin, auth status).
class SecurityInfo {
  const SecurityInfo({
    required this.userId,
    required this.transactionPinSet,
    required this.lastLogin,
  });

  final String userId;
  final bool transactionPinSet;
  final String lastLogin;
}
