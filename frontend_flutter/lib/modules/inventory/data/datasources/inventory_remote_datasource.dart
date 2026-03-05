import '../models/inventory_balance_model.dart';
import '../models/inventory_item_model.dart';

/// DataSource talks to API. Uses Dio from core/network via injector.
abstract class InventoryRemoteDataSource {
  Future<List<InventoryItemModel>> fetchItems({int page = 1, int pageSize = 20});

  /// Tồn kho hiện tại: GET /api/v1/inventory?warehouseType=raw|semi|finished
  Future<({List<InventoryBalanceModel> items, int total})> fetchBalance({
    required String warehouseType,
    int page = 1,
    int pageSize = 20,
  });
}
