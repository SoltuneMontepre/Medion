import '../models/order_detail_model.dart';
import '../models/product_suggest_model.dart';
import '../models/sale_order_model.dart';
import '../../domain/entities/order_summary.dart';

/// DataSource talks to API. Uses Dio from core/network via injector.
abstract class SalesRemoteDataSource {
  Future<List<SaleOrderModel>> fetchOrders({int page = 1, int pageSize = 20});

  /// GET /api/v1/sale/order-summaries (list for current sale admin)
  Future<OrderSummaryListResult> fetchOrderSummaries({
    int page = 1,
    int pageSize = 20,
  });

  /// GET /api/v1/sale/order-summaries/by-date?date=yyyy-MM-dd
  Future<OrderSummary?> fetchOrderSummaryByDate(String dateYyyyMmDd);

  /// GET /api/v1/sale/order-summaries/:id
  Future<OrderSummary?> fetchOrderSummaryById(String id);

  /// GET /api/v1/sale/orders/check-today?customerId=...
  Future<CheckCustomerOrderTodayResult> checkCustomerOrderToday(String customerId);

  /// POST /api/v1/sale/orders
  Future<OrderDetailModel> createOrder({
    required String customerId,
    required List<OrderItemRequest> items,
    required String pin,
  });

  /// GET /api/v1/sale/orders/:id
  Future<OrderDetailModel> getOrderById(String orderId);

  /// GET /api/v1/sale/products/suggest?q=...
  Future<List<ProductSuggestModel>> fetchProductSuggest(String query);
}

class CheckCustomerOrderTodayResult {
  const CheckCustomerOrderTodayResult({
    required this.hasOrderToday,
    this.existingOrderId,
    this.nextOrderNumber,
  });
  final bool hasOrderToday;
  final String? existingOrderId;
  final String? nextOrderNumber;
}

class OrderItemRequest {
  const OrderItemRequest({required this.productId, required this.quantity});
  final String productId;
  final int quantity;
}
