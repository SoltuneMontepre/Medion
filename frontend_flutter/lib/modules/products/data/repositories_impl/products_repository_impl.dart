import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/product.dart';
import '../../domain/entities/product_list_result.dart';
import '../../domain/repositories/products_repository.dart';
import '../datasources/products_remote_datasource.dart';
import '../datasources/products_remote_datasource_impl.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  ProductsRepositoryImpl(this._dataSource);

  final ProductsRemoteDataSource _dataSource;

  @override
  Future<ProductListResult> getProducts({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dataSource.fetchProducts(
      page: page,
      pageSize: pageSize,
    );
    return ProductListResult(
      items: response.items.map((m) => m.toEntity()).toList(),
      total: response.total,
    );
  }

  @override
  Future<Product?> getProductById(String id) =>
      _dataSource.fetchProductById(id);

  @override
  Future<Product> createProduct(ProductMutationParams params) =>
      _dataSource.createProduct(params);

  @override
  Future<Product> updateProduct(String id, ProductMutationParams params) =>
      _dataSource.updateProduct(id, params);

  @override
  Future<void> deleteProduct(String id) => _dataSource.deleteProduct(id);
}

final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  final dataSource = ref.watch(productsRemoteDataSourceProvider);
  return ProductsRepositoryImpl(dataSource);
});
