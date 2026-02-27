import '../entities/payroll_record.dart';
import '../repositories/payroll_repository.dart';

/// UseCase handles business logic. Presentation calls UseCases only.
class GetPayrollRecords {
  GetPayrollRecords(this._repository);

  final PayrollRepository _repository;

  Future<List<PayrollRecord>> call({int page = 1, int pageSize = 20}) {
    return _repository.getRecords(page: page, pageSize: pageSize);
  }
}
