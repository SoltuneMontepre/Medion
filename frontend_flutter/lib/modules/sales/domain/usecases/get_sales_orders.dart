import '../entities/sale_order.dart';
import '../repositories/sales_repository.dart';

/// UseCase handles business logic. Presentation calls UseCases only.
class GetSalesOrders {
  GetSalesOrders(this._repository);

  final SalesRepository _repository;

  Future<SaleOrdersListResult> call(OrdersListQuery query) {
    return _repository.getOrders(query);
  }
}
