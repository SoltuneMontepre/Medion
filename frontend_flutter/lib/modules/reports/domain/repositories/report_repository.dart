import '../entities/report.dart';

/// Repository interface in domain. Implementation lives in data.
abstract class ReportRepository {
  Future<List<Report>> getReports({int page = 1, int pageSize = 20});
}
