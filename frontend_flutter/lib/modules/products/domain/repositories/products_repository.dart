import '../entities/product.dart';
import '../entities/product_list_result.dart';

abstract class ProductsRepository {
  Future<ProductListResult> getProducts({int page = 1, int pageSize = 20});

  Future<Product?> getProductById(String id);

  Future<Product> createProduct(ProductMutationParams params);

  Future<Product> updateProduct(String id, ProductMutationParams params);

  Future<void> deleteProduct(String id);
}
