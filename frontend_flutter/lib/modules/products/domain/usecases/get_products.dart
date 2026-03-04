import '../entities/product_list_result.dart';
import '../repositories/products_repository.dart';

class GetProducts {
  GetProducts(this._repository);

  final ProductsRepository _repository;

  Future<ProductListResult> call({int page = 1, int pageSize = 20}) {
    return _repository.getProducts(page: page, pageSize: pageSize);
  }
}
