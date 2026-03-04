import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/role.dart';
import '../../domain/repositories/roles_repository.dart';
import '../datasources/roles_remote_datasource.dart';
import '../datasources/roles_remote_datasource_impl.dart';

class RolesRepositoryImpl implements RolesRepository {
  RolesRepositoryImpl(this._dataSource);

  final RolesRemoteDataSource _dataSource;

  @override
  Future<RoleListResult> getRoles({int page = 1, int pageSize = 20}) async {
    final response = await _dataSource.fetchRoles(page: page, pageSize: pageSize);
    return RoleListResult(
      items: response.items.map((m) => m.toEntity()).toList(),
      total: response.total,
    );
  }

  @override
  Future<List<Role>> getAllRoles() async {
    final list = await _dataSource.fetchAllRoles();
    return list.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Role?> getRoleById(String id) => _dataSource.fetchRoleById(id);

  @override
  Future<Role> createRole(RoleMutationParams params) =>
      _dataSource.createRole(params);

  @override
  Future<Role> updateRole(String id, RoleMutationParams params) =>
      _dataSource.updateRole(id, params);

  @override
  Future<void> deleteRole(String id) => _dataSource.deleteRole(id);
}

final rolesRepositoryProvider = Provider<RolesRepository>((ref) {
  final dataSource = ref.watch(rolesRemoteDataSourceProvider);
  return RolesRepositoryImpl(dataSource);
});
