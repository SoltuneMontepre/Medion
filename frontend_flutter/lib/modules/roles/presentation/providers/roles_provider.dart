import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories_impl/roles_repository_impl.dart';
import '../../data/repositories_impl/user_roles_repository_impl.dart';
import '../../domain/entities/role.dart';
import '../../domain/repositories/roles_repository.dart';
import '../../domain/repositories/user_roles_repository.dart';

final rolesProvider =
    FutureProvider.autoDispose.family<RoleListResult, int>((ref, page) {
  final repository = ref.watch(rolesRepositoryProvider);
  return repository.getRoles(page: page, pageSize: 20);
});

final allRolesProvider = FutureProvider.autoDispose<List<Role>>((ref) {
  final repository = ref.watch(rolesRepositoryProvider);
  return repository.getAllRoles();
});

final usersProvider =
    FutureProvider.autoDispose.family<UsersListResult, int>((ref, page) {
  final repository = ref.watch(userRolesRepositoryProvider);
  return repository.getUsers(page: page, pageSize: 20);
});

final userRolesProvider =
    FutureProvider.autoDispose.family<List<Role>, String>((ref, userId) {
  final repository = ref.watch(userRolesRepositoryProvider);
  return repository.getUserRoles(userId);
});
