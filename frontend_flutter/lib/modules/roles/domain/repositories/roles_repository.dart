import '../entities/role.dart';

abstract class RolesRepository {
  Future<RoleListResult> getRoles({int page = 1, int pageSize = 20});

  /// All roles for hierarchy editor.
  Future<List<Role>> getAllRoles();

  Future<Role?> getRoleById(String id);

  Future<Role> createRole(RoleMutationParams params);

  Future<Role> updateRole(String id, RoleMutationParams params);

  Future<void> deleteRole(String id);
}

class RoleListResult {
  const RoleListResult({required this.items, required this.total});
  final List<Role> items;
  final int total;
}
