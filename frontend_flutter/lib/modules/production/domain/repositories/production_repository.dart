import '../entities/production_order.dart';

/// Repository interface in domain. Implementation lives in data.
abstract class ProductionRepository {
  Future<List<ProductionOrder>> getOrders({int page = 1, int pageSize = 20});
}
