import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/role.dart';
import '../../domain/repositories/user_roles_repository.dart';
import '../datasources/user_roles_remote_datasource.dart';
import '../datasources/user_roles_remote_datasource_impl.dart';

class UserRolesRepositoryImpl implements UserRolesRepository {
  UserRolesRepositoryImpl(this._dataSource);

  final UserRolesRemoteDataSource _dataSource;

  @override
  Future<UsersListResult> getUsers({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response =
        await _dataSource.fetchUsers(page: page, pageSize: pageSize);
    return UsersListResult(
      items: response.items.map((m) => m.toEntity()).toList(),
      total: response.total,
    );
  }

  @override
  Future<List<Role>> getUserRoles(String userId) async {
    final list = await _dataSource.fetchUserRoles(userId);
    return list.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> setUserRoles(String userId, List<String> roleIds) =>
      _dataSource.setUserRoles(userId, roleIds);
}

final userRolesRepositoryProvider = Provider<UserRolesRepository>((ref) {
  final dataSource = ref.watch(userRolesRemoteDataSourceProvider);
  return UserRolesRepositoryImpl(dataSource);
});
