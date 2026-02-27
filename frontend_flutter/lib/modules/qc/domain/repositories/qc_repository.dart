import '../entities/qc_inspection.dart';

/// Repository interface in domain. Implementation lives in data.
abstract class QcRepository {
  Future<List<QcInspection>> getInspections({int page = 1, int pageSize = 20});
}
