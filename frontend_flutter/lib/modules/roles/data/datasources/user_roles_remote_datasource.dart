import '../models/role_model.dart';
import '../models/user_model.dart';

/// API for list users and get/set user roles (assign role to user screen).
abstract class UserRolesRemoteDataSource {
  Future<UsersListResponse> fetchUsers({int page = 1, int pageSize = 20});

  Future<List<RoleModel>> fetchUserRoles(String userId);

  Future<void> setUserRoles(String userId, List<String> roleIds);

  /// Sets or clears the user's direct supervisor. Pass null to clear.
  Future<void> setSupervisor(String userId, String? supervisorId);
}

class UsersListResponse {
  const UsersListResponse({required this.items, required this.total});
  final List<UserModel> items;
  final int total;
}
