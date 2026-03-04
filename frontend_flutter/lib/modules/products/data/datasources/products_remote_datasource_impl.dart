import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client_provider.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/product.dart';
import '../models/product_model.dart';
import 'products_remote_datasource.dart';

class ProductsRemoteDataSourceImpl implements ProductsRemoteDataSource {
  ProductsRemoteDataSourceImpl(this._client);

  final DioClient _client;

  static const _salePath = '/api/v1/sale';

  @override
  Future<ProductsListResponse> fetchProducts({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _client.dio.get(
      '$_salePath/products',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    final json = response.data;
    if (json is! Map<String, dynamic>) {
      return const ProductsListResponse(items: [], total: 0);
    }
    final data = json['data'];
    if (data is! Map<String, dynamic>) {
      return const ProductsListResponse(items: [], total: 0);
    }
    final itemsRaw = data['items'];
    final totalRaw = data['total'];
    final items = itemsRaw is List
        ? (itemsRaw)
            .whereType<Map<String, dynamic>>()
            .map(ProductModel.fromJson)
            .toList()
        : <ProductModel>[];
    final total = totalRaw is int ? totalRaw : items.length;
    return ProductsListResponse(items: items, total: total);
  }

  @override
  Future<Product?> fetchProductById(String id) async {
    try {
      final response = await _client.dio.get('$_salePath/products/$id');
      final json = response.data;
      if (json is! Map<String, dynamic>) return null;
      final model = parseData(json, ProductModel.fromJson);
      return model?.toEntity();
    } on DioException {
      return null;
    }
  }

  @override
  Future<Product> createProduct(ProductMutationParams params) async {
    final body = {
      'code': params.code,
      'name': params.name,
      'packageSize': params.packageSize,
      'packageUnit': params.packageUnit,
      'productType': params.productType,
      'packagingType': params.packagingType,
    };
    final response = await _client.dio.post('$_salePath/products', data: body);
    final json = response.data;
    if (json is! Map<String, dynamic>) throw Exception(apiMessage(json) ?? 'Lỗi lưu sản phẩm');
    final model = parseData(json, ProductModel.fromJson);
    if (model == null) throw Exception(apiMessage(json) ?? 'Lỗi lưu sản phẩm');
    return model.toEntity();
  }

  @override
  Future<Product> updateProduct(String id, ProductMutationParams params) async {
    final body = {
      'code': params.code,
      'name': params.name,
      'packageSize': params.packageSize,
      'packageUnit': params.packageUnit,
      'productType': params.productType,
      'packagingType': params.packagingType,
    };
    final response = await _client.dio.put('$_salePath/products/$id', data: body);
    final json = response.data;
    if (json is! Map<String, dynamic>) throw Exception(apiMessage(json) ?? 'Lỗi cập nhật sản phẩm');
    final model = parseData(json, ProductModel.fromJson);
    if (model == null) throw Exception(apiMessage(json) ?? 'Lỗi cập nhật sản phẩm');
    return model.toEntity();
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _client.dio.delete('$_salePath/products/$id');
  }
}

final productsRemoteDataSourceProvider =
    Provider<ProductsRemoteDataSource>((ref) {
  final client = ref.watch(apiClientProvider);
  return ProductsRemoteDataSourceImpl(client);
});
