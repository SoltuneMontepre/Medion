import '../entities/order_summary.dart';
import '../entities/sale_order.dart';

/// Repository interface in domain. Implementation lives in data.
abstract class SalesRepository {
  Future<List<SaleOrder>> getOrders({int page = 1, int pageSize = 20});

  /// List order summaries for current sale admin (read-only).
  Future<OrderSummaryListResult> getOrderSummaries({
    int page = 1,
    int pageSize = 20,
  });

  /// dateYyyyMmDd: yyyy-MM-dd. Returns null if none for that date.
  Future<OrderSummary?> getOrderSummaryByDate(String dateYyyyMmDd);

  /// Returns null if not found or not owned by current user.
  Future<OrderSummary?> getOrderSummaryById(String id);
}
