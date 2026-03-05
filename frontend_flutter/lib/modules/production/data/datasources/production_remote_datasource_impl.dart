import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client_provider.dart';
import '../../../../core/network/dio_client.dart';
import '../models/production_order_model.dart';
import 'production_remote_datasource.dart';

class ProductionRemoteDataSourceImpl implements ProductionRemoteDataSource {
  ProductionRemoteDataSourceImpl(this._client);

  final DioClient _client;

  static const _path = '/api/v1/production-orders';

  Map<String, dynamic> _parseResponse(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is String) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    throw FormatException('Unexpected response type: ${data.runtimeType}');
  }

  @override
  Future<List<ProductionOrderModel>> fetchOrders({
    int limit = 20,
    int offset = 0,
    String? status,
  }) async {
    final params = <String, dynamic>{'limit': limit, 'offset': offset};
    if (status != null && status.isNotEmpty) {
      params['status'] = status;
    }
    final res = await _client.dio.get(_path, queryParameters: params);
    final data = _parseResponse(res.data);
    final raw = data['data'] as Map<String, dynamic>?;
    if (raw == null) return [];
    final items = raw['items'] as List<dynamic>? ?? [];
    return items
        .map((e) => ProductionOrderModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ProductionOrderModel> create(Map<String, dynamic> body) async {
    final res = await _client.dio.post(_path, data: body);
    final data = _parseResponse(res.data);
    final raw = data['data'] as Map<String, dynamic>?;
    if (raw == null) throw DioException(requestOptions: res.requestOptions);
    return ProductionOrderModel.fromJson(raw);
  }

  @override
  Future<ProductionOrderModel?> getById(String id) async {
    try {
      final res = await _client.dio.get('$_path/$id');
      final data = _parseResponse(res.data);
      final raw = data['data'] as Map<String, dynamic>?;
      if (raw == null) return null;
      return ProductionOrderModel.fromJson(raw);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }
}

final productionRemoteDataSourceProvider =
    Provider<ProductionRemoteDataSource>((ref) {
  final client = ref.watch(apiClientProvider);
  return ProductionRemoteDataSourceImpl(client);
});
