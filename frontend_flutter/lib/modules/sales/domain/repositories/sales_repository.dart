import '../entities/order_summary.dart';
import '../entities/sale_order.dart';

/// Repository interface in domain. Implementation lives in data.
abstract class SalesRepository {
  Future<List<SaleOrder>> getOrders({int page = 1, int pageSize = 20});

  /// dateYyyyMmDd: yyyy-MM-dd
  Future<OrderSummary> getOrderSummary(String dateYyyyMmDd);
}
