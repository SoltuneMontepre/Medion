import '../models/payroll_record_model.dart';

/// DataSource talks to API. Uses Dio from core/network via injector.
abstract class PayrollRemoteDataSource {
  Future<List<PayrollRecordModel>> fetchRecords({int page = 1, int pageSize = 20});
}
