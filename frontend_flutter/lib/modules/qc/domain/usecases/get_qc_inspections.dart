import '../entities/qc_inspection.dart';
import '../repositories/qc_repository.dart';

/// UseCase handles business logic. Presentation calls UseCases only.
class GetQcInspections {
  GetQcInspections(this._repository);

  final QcRepository _repository;

  Future<List<QcInspection>> call({int page = 1, int pageSize = 20}) {
    return _repository.getInspections(page: page, pageSize: pageSize);
  }
}
