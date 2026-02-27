import '../entities/inventory_item.dart';

/// Repository interface in domain. Implementation lives in data.
abstract class InventoryRepository {
  Future<List<InventoryItem>> getItems({int page = 1, int pageSize = 20});
}
