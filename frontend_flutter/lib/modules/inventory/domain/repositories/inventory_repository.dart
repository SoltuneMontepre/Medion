import '../entities/inventory_balance.dart';
import '../entities/inventory_item.dart';

/// Repository interface in domain. Implementation lives in data.
abstract class InventoryRepository {
  Future<List<InventoryItem>> getItems({int page = 1, int pageSize = 20});

  /// Tồn kho hiện tại by warehouse type (raw | semi | finished).
  Future<({List<InventoryBalance> items, int total})> getBalance({
    required String warehouseType,
    int page = 1,
    int pageSize = 20,
  });
}
