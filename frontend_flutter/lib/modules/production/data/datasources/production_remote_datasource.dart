import '../models/production_order_model.dart';

/// DataSource talks to API. Uses Dio from core/network via injector.
abstract class ProductionRemoteDataSource {
  Future<List<ProductionOrderModel>> fetchOrders({int page = 1, int pageSize = 20});
}
