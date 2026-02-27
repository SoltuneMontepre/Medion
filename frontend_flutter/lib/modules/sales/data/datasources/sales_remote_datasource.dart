import '../../domain/entities/order_summary.dart';
import '../models/sale_order_model.dart';

/// DataSource talks to API. Uses Dio from core/network via injector.
abstract class SalesRemoteDataSource {
  Future<List<SaleOrderModel>> fetchOrders({int page = 1, int pageSize = 20});

  /// GET /api/sale/orders/daily-summary?date=yyyy-MM-dd
  Future<OrderSummary> fetchDailyOrderSummary(String dateYyyyMmDd);
}
