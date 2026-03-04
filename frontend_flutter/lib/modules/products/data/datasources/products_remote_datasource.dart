import '../../domain/entities/product.dart';
import '../models/product_model.dart';

class ProductsListResponse {
  const ProductsListResponse({required this.items, required this.total});
  final List<ProductModel> items;
  final int total;
}

abstract class ProductsRemoteDataSource {
  Future<ProductsListResponse> fetchProducts({
    int page = 1,
    int pageSize = 20,
  });

  Future<Product?> fetchProductById(String id);

  Future<Product> createProduct(ProductMutationParams params);

  Future<Product> updateProduct(String id, ProductMutationParams params);

  Future<void> deleteProduct(String id);
}
