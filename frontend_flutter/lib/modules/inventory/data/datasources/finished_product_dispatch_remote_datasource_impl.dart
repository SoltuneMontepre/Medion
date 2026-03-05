import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client_provider.dart';
import '../../../../core/network/dio_client.dart';
import '../models/finished_product_release_model.dart';
import 'finished_product_dispatch_remote_datasource.dart';

class FinishedProductDispatchRemoteDataSourceImpl
    implements FinishedProductDispatchRemoteDataSource {
  FinishedProductDispatchRemoteDataSourceImpl(this._client);

  final DioClient _client;

  static const _path = '/api/v1/finished-product-dispatches';

  @override
  Future<({List<FinishedProductReleaseModel> items, int total})> list({
    String? status,
    int limit = 20,
    int offset = 0,
  }) async {
    final query = <String, dynamic>{
      'limit': limit,
      'offset': offset,
    };
    if (status != null && status.isNotEmpty) {
      query['status'] = status;
    }
    final res = await _client.dio.get<Map<String, dynamic>>(
      _path,
      queryParameters: query,
    );
    final data = res.data;
    if (data == null) {
      return (items: <FinishedProductReleaseModel>[], total: 0);
    }
    final raw = data['data'];
    if (raw == null) {
      return (items: <FinishedProductReleaseModel>[], total: 0);
    }
    final map = raw as Map<String, dynamic>;
    final itemsList = map['items'] as List<dynamic>? ?? [];
    final items = itemsList
        .map<FinishedProductReleaseModel>(
            (e) => FinishedProductReleaseModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final total = (map['total'] as num?)?.toInt() ?? 0;
    return (items: items, total: total);
  }

  @override
  Future<FinishedProductReleaseModel?> getById(String id) async {
    try {
      final res = await _client.dio.get<Map<String, dynamic>>('$_path/$id');
      final data = res.data;
      if (data == null) return null;
      final raw = data['data'];
      if (raw == null) return null;
      return FinishedProductReleaseModel.fromJson(raw as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<FinishedProductReleaseModel> create({
    required String customerId,
    required String orderNumber,
    required String address,
    required String phone,
    required List<Map<String, dynamic>> items,
  }) async {
    final res = await _client.dio.post<Map<String, dynamic>>(
      _path,
      data: {
        'customerId': customerId,
        'orderNumber': orderNumber,
        'address': address,
        'phone': phone,
        'items': items,
      },
    );
    final data = res.data;
    if (data == null) throw DioException(requestOptions: res.requestOptions);
    final raw = data['data'] as Map<String, dynamic>?;
    if (raw == null) throw DioException(requestOptions: res.requestOptions);
    return FinishedProductReleaseModel.fromJson(raw);
  }

  @override
  Future<FinishedProductReleaseModel> update(
    String id, {
    required String orderNumber,
    required String address,
    required String phone,
    required List<Map<String, dynamic>> items,
  }) async {
    final res = await _client.dio.put<Map<String, dynamic>>(
      '$_path/$id',
      data: {
        'orderNumber': orderNumber,
        'address': address,
        'phone': phone,
        'items': items,
      },
    );
    final data = res.data;
    if (data == null) throw DioException(requestOptions: res.requestOptions);
    final raw = data['data'] as Map<String, dynamic>?;
    if (raw == null) throw DioException(requestOptions: res.requestOptions);
    return FinishedProductReleaseModel.fromJson(raw);
  }

  @override
  Future<FinishedProductReleaseModel> submit(String id) async {
    final res = await _client.dio.post<Map<String, dynamic>>('$_path/$id/submit');
    final data = res.data;
    if (data == null) throw DioException(requestOptions: res.requestOptions);
    final raw = data['data'] as Map<String, dynamic>?;
    if (raw == null) throw DioException(requestOptions: res.requestOptions);
    return FinishedProductReleaseModel.fromJson(raw);
  }

  @override
  Future<FinishedProductReleaseModel> approve(String id) async {
    final res = await _client.dio.post<Map<String, dynamic>>('$_path/$id/approve');
    final data = res.data;
    if (data == null) throw DioException(requestOptions: res.requestOptions);
    final raw = data['data'] as Map<String, dynamic>?;
    if (raw == null) throw DioException(requestOptions: res.requestOptions);
    return FinishedProductReleaseModel.fromJson(raw);
  }

  @override
  Future<FinishedProductReleaseModel> reject(String id, String reason) async {
    final res = await _client.dio.post<Map<String, dynamic>>(
      '$_path/$id/reject',
      data: {'reason': reason},
    );
    final data = res.data;
    if (data == null) throw DioException(requestOptions: res.requestOptions);
    final raw = data['data'] as Map<String, dynamic>?;
    if (raw == null) throw DioException(requestOptions: res.requestOptions);
    return FinishedProductReleaseModel.fromJson(raw);
  }

  static const _salePath = '/api/v1/sale';

  @override
  Future<List<CustomerSuggestItem>> suggestCustomers(String query) async {
    if (query.trim().isEmpty) return [];
    final res = await _client.dio.get<Map<String, dynamic>>(
      '$_salePath/customers/suggest',
      queryParameters: {'q': query},
    );
    final data = res.data;
    if (data == null) return [];
    final raw = data['data'];
    if (raw == null) return [];
    final list = raw is List ? raw : <dynamic>[];
    return list
        .map((e) {
          final m = e as Map<String, dynamic>;
          return CustomerSuggestItem(
            id: m['id']?.toString() ?? '',
            code: m['code'] as String? ?? '',
            name: m['name'] as String? ?? '',
            address: m['address'] as String?,
            phone: m['phone'] as String?,
          );
        })
        .where((e) => e.id.isNotEmpty)
        .toList();
  }

  @override
  Future<List<ProductSuggestItem>> suggestProducts(String query) async {
    if (query.trim().isEmpty) return [];
    final res = await _client.dio.get<Map<String, dynamic>>(
      '$_salePath/products/suggest',
      queryParameters: {'q': query},
    );
    final data = res.data;
    if (data == null) return [];
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

final finishedProductDispatchRemoteDataSourceProvider =
    Provider<FinishedProductDispatchRemoteDataSource>((ref) {
  final client = ref.watch(apiClientProvider);
  return FinishedProductDispatchRemoteDataSourceImpl(client);
});
