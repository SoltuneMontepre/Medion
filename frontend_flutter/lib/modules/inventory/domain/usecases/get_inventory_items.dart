import '../entities/inventory_item.dart';
import '../repositories/inventory_repository.dart';

/// UseCase handles business logic. Presentation calls UseCases only.
class GetInventoryItems {
  GetInventoryItems(this._repository);

  final InventoryRepository _repository;

  Future<List<InventoryItem>> call({int page = 1, int pageSize = 20}) {
    return _repository.getItems(page: page, pageSize: pageSize);
  }
}
