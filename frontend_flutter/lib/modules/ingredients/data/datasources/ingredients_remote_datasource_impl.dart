import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client_provider.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/ingredient.dart';
import '../../domain/repositories/ingredients_repository.dart';
import '../models/ingredient_model.dart';
import 'ingredients_remote_datasource.dart';

class IngredientsRemoteDataSourceImpl implements IngredientsRemoteDataSource {
  IngredientsRemoteDataSourceImpl(this._client);

  final DioClient _client;

  static const _path = '/api/v1/ingredients';

  Map<String, dynamic> _parseResponse(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is String) return jsonDecode(data) as Map<String, dynamic>;
    throw FormatException('Unexpected response type: ${data.runtimeType}');
  }

  @override
  Future<IngredientsListResponse> fetchIngredients({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _client.dio.get(
      _path,
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    final json = _parseResponse(response.data);
    final data = json['data'] as Map<String, dynamic>?;
    if (data == null) return const IngredientsListResponse(items: [], total: 0);
    final itemsRaw = data['items'] as List<dynamic>? ?? [];
    final total = data['total'] as int? ?? 0;
    final items = itemsRaw
        .whereType<Map<String, dynamic>>()
        .map(IngredientModel.fromJson)
        .toList();
    return IngredientsListResponse(items: items, total: total);
  }

  @override
  Future<Ingredient?> fetchIngredientById(String id) async {
    try {
      final response = await _client.dio.get('$_path/$id');
      final json = _parseResponse(response.data);
      final model = parseData(json, IngredientModel.fromJson);
      return model?.toEntity();
    } on DioException {
      return null;
    }
  }

  @override
  Future<Ingredient> createIngredient(IngredientMutationParams params) async {
    final body = {
      'code': params.code,
      'name': params.name,
      'unit': params.unit,
      'description': params.description,
    };
    final response = await _client.dio.post(_path, data: body);
    final json = _parseResponse(response.data);
    final model = parseData(json, IngredientModel.fromJson);
    if (model == null) throw Exception(apiMessage(json) ?? 'Lỗi lưu nguyên liệu');
    return model.toEntity();
  }

  @override
  Future<Ingredient> updateIngredient(String id, IngredientMutationParams params) async {
    final body = {
      'code': params.code,
      'name': params.name,
      'unit': params.unit,
      'description': params.description,
    };
    final response = await _client.dio.put('$_path/$id', data: body);
    final json = _parseResponse(response.data);
    final model = parseData(json, IngredientModel.fromJson);
    if (model == null) throw Exception(apiMessage(json) ?? 'Lỗi cập nhật nguyên liệu');
    return model.toEntity();
  }

  @override
  Future<void> deleteIngredient(String id) async {
    await _client.dio.delete('$_path/$id');
  }

  @override
  Future<List<Ingredient>> suggestIngredients(String query) async {
    if (query.trim().isEmpty) return [];
    final response = await _client.dio.get(
      '$_path/suggest',
      queryParameters: {'q': query},
    );
    final json = _parseResponse(response.data);
    final data = json['data'];
    if (data == null) return [];
    final list = data is List ? data : <dynamic>[];
    return list
        .whereType<Map<String, dynamic>>()
        .map((m) => IngredientModel.fromJson(m).toEntity())
        .toList();
  }
}

final ingredientsRemoteDataSourceProvider =
    Provider<IngredientsRemoteDataSource>((ref) {
  final client = ref.watch(apiClientProvider);
  return IngredientsRemoteDataSourceImpl(client);
});
