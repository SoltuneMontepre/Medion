import '../entities/report.dart';
import '../repositories/report_repository.dart';

/// UseCase handles business logic. Presentation calls UseCases only.
class GetReports {
  GetReports(this._repository);

  final ReportRepository _repository;

  Future<List<Report>> call({int page = 1, int pageSize = 20}) {
    return _repository.getReports(page: page, pageSize: pageSize);
  }
}
