/// Lightweight user for list and assign-role / assign-supervisor screens.
class User {
  const User({
    required this.id,
    required this.username,
    required this.email,
    this.supervisorId,
    this.supervisorUsername,
  });

  final String id;
  final String username;
  final String email;
  final String? supervisorId;
  final String? supervisorUsername;
}
