import '../models/inventory_item_model.dart';

/// DataSource talks to API. Uses Dio from core/network via injector.
abstract class InventoryRemoteDataSource {
  Future<List<InventoryItemModel>> fetchItems({int page = 1, int pageSize = 20});
}
