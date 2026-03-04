import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client_provider.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/role.dart';
import '../models/role_model.dart';
import 'roles_remote_datasource.dart';

T? _parseData<T>(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJson) {
  final data = json['data'];
  if (data == null) return null;
  if (data is! Map<String, dynamic>) return null;
  return fromJson(data);
}

List<T> _parseList<T>(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJson) {
  final data = json['data'];
  if (data == null) return [];
  if (data is! List) return [];
  return data.whereType<Map<String, dynamic>>().map(fromJson).toList();
}

class RolesRemoteDataSourceImpl implements RolesRemoteDataSource {
  RolesRemoteDataSourceImpl(this._client);

  final DioClient _client;

  static const _path = '/api/v1/roles';

  @override
  Future<RolesListResponse> fetchRoles({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _client.dio.get(
      _path,
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    final json = response.data;
    if (json is! Map<String, dynamic>) {
      return const RolesListResponse(items: [], total: 0);
    }
    final data = json['data'];
    if (data is! Map<String, dynamic>) {
      return const RolesListResponse(items: [], total: 0);
    }
    final itemsRaw = data['items'];
    final totalRaw = data['total'];
    final items = itemsRaw is List
        ? (itemsRaw).whereType<Map<String, dynamic>>().map(RoleModel.fromJson).toList()
        : <RoleModel>[];
    final total = totalRaw is int ? totalRaw : items.length;
    return RolesListResponse(items: items, total: total);
  }

  @override
  Future<List<RoleModel>> fetchAllRoles() async {
    final response = await _client.dio.get('$_path/all');
    final json = response.data;
    if (json is! Map<String, dynamic>) return [];
    final list = _parseList<RoleModel>(json, RoleModel.fromJson);
    return list;
  }

  @override
  Future<Role?> fetchRoleById(String id) async {
    try {
      final response = await _client.dio.get('$_path/$id');
      final json = response.data;
      if (json is! Map<String, dynamic>) return null;
      final model = _parseData(json, RoleModel.fromJson);
      return model?.toEntity();
    } on DioException {
      return null;
    }
  }

  @override
  Future<Role> createRole(RoleMutationParams params) async {
    final body = <String, dynamic>{
      'code': params.code,
      'name': params.name,
      'description': params.description,
      if (params.parentRoleId != null && params.parentRoleId!.isNotEmpty) 'parentRoleId': params.parentRoleId,
    };
    final response = await _client.dio.post(_path, data: body);
    final json = response.data;
    if (json is! Map<String, dynamic>) throw Exception('Invalid response');
    final model = _parseData(json, RoleModel.fromJson);
    if (model == null) throw Exception('Invalid response');
    return model.toEntity();
  }

  @override
  Future<Role> updateRole(String id, RoleMutationParams params) async {
    final body = <String, dynamic>{
      'code': params.code,
      'name': params.name,
      'description': params.description,
      if (params.parentRoleId != null && params.parentRoleId!.isNotEmpty) 'parentRoleId': params.parentRoleId,
    };
    final response = await _client.dio.put('$_path/$id', data: body);
    final json = response.data;
    if (json is! Map<String, dynamic>) throw Exception('Invalid response');
    final model = _parseData(json, RoleModel.fromJson);
    if (model == null) throw Exception('Invalid response');
    return model.toEntity();
  }

  @override
  Future<void> deleteRole(String id) async {
    await _client.dio.delete('$_path/$id');
  }
}

final rolesRemoteDataSourceProvider = Provider<RolesRemoteDataSource>((ref) {
  final client = ref.watch(apiClientProvider);
  return RolesRemoteDataSourceImpl(client);
});
