import '../models/role_model.dart';
import '../../domain/entities/role.dart';

abstract class RolesRemoteDataSource {
  Future<RolesListResponse> fetchRoles({int page = 1, int pageSize = 20});

  /// All roles (no paging) for hierarchy display.
  Future<List<RoleModel>> fetchAllRoles();

  Future<Role?> fetchRoleById(String id);

  Future<Role> createRole(RoleMutationParams params);

  Future<Role> updateRole(String id, RoleMutationParams params);

  Future<void> deleteRole(String id);
}

class RolesListResponse {
  const RolesListResponse({required this.items, required this.total});
  final List<RoleModel> items;
  final int total;
}
