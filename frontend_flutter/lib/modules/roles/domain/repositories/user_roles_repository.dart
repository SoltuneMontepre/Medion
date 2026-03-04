import '../entities/role.dart';
import '../entities/user.dart';

abstract class UserRolesRepository {
  Future<UsersListResult> getUsers({int page = 1, int pageSize = 20});

  Future<List<Role>> getUserRoles(String userId);

  Future<void> setUserRoles(String userId, List<String> roleIds);

  /// Sets or clears the user's direct supervisor. Pass null to clear.
  Future<void> setSupervisor(String userId, String? supervisorId);
}

class UsersListResult {
  const UsersListResult({required this.items, required this.total});
  final List<User> items;
  final int total;
}
