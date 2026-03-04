import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client_provider.dart';
import '../../../../core/network/dio_client.dart';
import '../models/role_model.dart';
import '../models/user_model.dart';
import 'user_roles_remote_datasource.dart';

T? _parseData<T>(
    Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJson) {
  final data = json['data'];
  if (data == null) return null;
  if (data is! Map<String, dynamic>) return null;
  return fromJson(data);
}

List<T> _parseList<T>(
    Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJson) {
  final data = json['data'];
  if (data == null) return [];
  if (data is! List) return [];
  return data.whereType<Map<String, dynamic>>().map(fromJson).toList();
}

class UserRolesRemoteDataSourceImpl implements UserRolesRemoteDataSource {
  UserRolesRemoteDataSourceImpl(this._client);

  final DioClient _client;

  static const _usersPath = '/api/v1/users';

  @override
  Future<UsersListResponse> fetchUsers({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _client.dio.get(
      _usersPath,
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    final json = response.data;
    if (json is! Map<String, dynamic>) {
      return const UsersListResponse(items: [], total: 0);
    }
    final data = json['data'];
    if (data is! Map<String, dynamic>) {
      return const UsersListResponse(items: [], total: 0);
    }
    final itemsRaw = data['items'];
    final totalRaw = data['total'];
    final items = itemsRaw is List
        ? (itemsRaw)
            .whereType<Map<String, dynamic>>()
            .map(UserModel.fromJson)
            .toList()
        : <UserModel>[];
    final total = totalRaw is int ? totalRaw : items.length;
    return UsersListResponse(items: items, total: total);
  }

  @override
  Future<List<RoleModel>> fetchUserRoles(String userId) async {
    final response = await _client.dio.get('$_usersPath/$userId/roles');
    final json = response.data;
    if (json is! Map<String, dynamic>) return [];
    return _parseList<RoleModel>(json, RoleModel.fromJson);
  }

  @override
  Future<void> setUserRoles(String userId, List<String> roleIds) async {
    await _client.dio.put(
      '$_usersPath/$userId/roles',
      data: {'roleIds': roleIds},
    );
  }

  @override
  Future<void> setSupervisor(String userId, String? supervisorId) async {
    await _client.dio.put(
      '$_usersPath/$userId/supervisor',
      data: {'supervisorId': supervisorId},
    );
  }
}

final userRolesRemoteDataSourceProvider =
    Provider<UserRolesRemoteDataSource>((ref) {
  final client = ref.watch(apiClientProvider);
  return UserRolesRemoteDataSourceImpl(client);
});
