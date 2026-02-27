import '../models/audit_log_model.dart';

/// DataSource talks to API. Uses Dio from core/network via injector.
abstract class AuditRemoteDataSource {
  Future<List<AuditLogModel>> fetchLogs({int page = 1, int pageSize = 20});
}
