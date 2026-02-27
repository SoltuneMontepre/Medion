import '../entities/payroll_record.dart';

/// Repository interface in domain. Implementation lives in data.
abstract class PayrollRepository {
  Future<List<PayrollRecord>> getRecords({int page = 1, int pageSize = 20});
}
