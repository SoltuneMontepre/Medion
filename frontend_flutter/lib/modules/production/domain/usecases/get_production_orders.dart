import '../entities/production_order.dart';
import '../repositories/production_repository.dart';

/// UseCase handles business logic. Presentation calls UseCases only.
class GetProductionOrders {
  GetProductionOrders(this._repository);

  final ProductionRepository _repository;

  Future<List<ProductionOrder>> call({int page = 1, int pageSize = 20}) {
    return _repository.getOrders(page: page, pageSize: pageSize);
  }
}
