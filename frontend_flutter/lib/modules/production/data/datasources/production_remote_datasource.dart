import '../models/production_order_model.dart';

/// DataSource talks to API. Uses Dio from core/network via injector.
abstract class ProductionRemoteDataSource {
  Future<List<ProductionOrderModel>> fetchOrders({
    int limit = 20,
    int offset = 0,
    String? status,
  });

  Future<ProductionOrderModel> create(Map<String, dynamic> body);

  Future<ProductionOrderModel?> getById(String id);
}
