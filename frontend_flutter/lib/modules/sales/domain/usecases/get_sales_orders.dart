import '../entities/sale_order.dart';
import '../repositories/sales_repository.dart';

/// UseCase handles business logic. Presentation calls UseCases only.
class GetSalesOrders {
  GetSalesOrders(this._repository);

  final SalesRepository _repository;

  Future<List<SaleOrder>> call({int page = 1, int pageSize = 20}) {
    return _repository.getOrders(page: page, pageSize: pageSize);
  }
}
