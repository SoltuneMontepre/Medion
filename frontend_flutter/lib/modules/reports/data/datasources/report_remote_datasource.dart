import '../models/report_model.dart';

/// DataSource talks to API. Uses Dio from core/network via injector.
abstract class ReportRemoteDataSource {
  Future<List<ReportModel>> fetchReports({int page = 1, int pageSize = 20});
}
