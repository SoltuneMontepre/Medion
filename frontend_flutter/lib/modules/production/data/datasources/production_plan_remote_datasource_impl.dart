import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client_provider.dart';
import '../../../../core/network/dio_client.dart';
import '../models/production_plan_model.dart';
import 'production_plan_remote_datasource.dart';

class ProductionPlanRemoteDataSourceImpl implements ProductionPlanRemoteDataSource {
  ProductionPlanRemoteDataSourceImpl(this._client);

  final DioClient _client;

  static const _path = '/api/v1/production-plans';

  /// Dio may return response.data as String when response type isn't parsed.
  /// Parse to Map when needed.
  Map<String, dynamic> _parseResponse(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is String) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    throw FormatException('Unexpected response type: ${data.runtimeType}');
  }

  @override
  Future<ProductionPlanModel?> getByDate(String dateYyyyMmDd) async {
    try {
      final res = await _client.dio.get(
        '$_path/by-date',
        queryParameters: {'date': dateYyyyMmDd},
      );
      final data = _parseResponse(res.data);
      final raw = data['data'];
      if (raw == null) return null;
      return ProductionPlanModel.fromJson(raw as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<ProductionPlanModel?> getById(String id) async {
    try {
      final res = await _client.dio.get('$_path/$id');
      final data = _parseResponse(res.data);
      final raw = data['data'];
      if (raw == null) return null;
      return ProductionPlanModel.fromJson(raw as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<ProductionPlanModel> create(
    String dateYyyyMmDd,
    List<Map<String, dynamic>> items,
  ) async {
    final res = await _client.dio.post(
      _path,
      data: {
        'planDate': dateYyyyMmDd,
        'items': items,
      },
    );
    final data = _parseResponse(res.data);
    final raw = data['data'] as Map<String, dynamic>?;
    if (raw == null) throw DioException(requestOptions: res.requestOptions);
    return ProductionPlanModel.fromJson(raw);
  }

  @override
  Future<ProductionPlanModel> update(
    String id,
    String dateYyyyMmDd,
    List<Map<String, dynamic>> items,
  ) async {
    final res = await _client.dio.put(
      '$_path/$id',
      data: {
        'planDate': dateYyyyMmDd,
        'items': items,
      },
    );
    final data = _parseResponse(res.data);
    final raw = data['data'] as Map<String, dynamic>?;
    if (raw == null) throw DioException(requestOptions: res.requestOptions);
    return ProductionPlanModel.fromJson(raw);
  }

  @override
  Future<ProductionPlanModel> submit(String planId) async {
    final res = await _client.dio.post('$_path/$planId/submit');
    final data = _parseResponse(res.data);
    final raw = data['data'] as Map<String, dynamic>?;
    if (raw == null) throw DioException(requestOptions: res.requestOptions);
    return ProductionPlanModel.fromJson(raw);
  }

  @override
  Future<ProductionPlanModel> approve(String planId) async {
    final res = await _client.dio.post('$_path/$planId/approve');
    final data = _parseResponse(res.data);
    final raw = data['data'] as Map<String, dynamic>?;
    if (raw == null) throw DioException(requestOptions: res.requestOptions);
    return ProductionPlanModel.fromJson(raw);
  }

  @override
  Future<ProductionPlanModel> reject(String planId, String reason) async {
    final res = await _client.dio.post(
      '$_path/$planId/reject',
      data: {'reason': reason},
    );
    final data = _parseResponse(res.data);
    final raw = data['data'] as Map<String, dynamic>?;
    if (raw == null) throw DioException(requestOptions: res.requestOptions);
    return ProductionPlanModel.fromJson(raw);
  }

  static const _salePath = '/api/v1/sale';

  @override
  Future<List<ProductSuggestItem>> suggestProducts(String query) async {
    if (query.trim().isEmpty) return [];
    final res = await _client.dio.get(
      '$_salePath/products/suggest',
      queryParameters: {'q': query},
    );
    final data = _parseResponse(res.data);
    final raw = data['data'];
    if (raw == null) return [];
    final list = raw is List ? raw : <dynamic>[];
    return list
        .map((e) {
          final m = e as Map<String, dynamic>;
          return ProductSuggestItem(
            id: m['id']?.toString() ?? '',
            code: m['code'] as String? ?? '',
            name: m['name'] as String? ?? '',
          );
        })
        .where((e) => e.id.isNotEmpty)
        .toList();
  }
}

final productionPlanRemoteDataSourceProvider =
    Provider<ProductionPlanRemoteDataSource>((ref) {
  final client = ref.watch(apiClientProvider);
  return ProductionPlanRemoteDataSourceImpl(client);
});
