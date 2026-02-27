import '../entities/audit_log.dart';

/// Repository interface in domain. Implementation lives in data.
abstract class AuditRepository {
  Future<List<AuditLog>> getLogs({int page = 1, int pageSize = 20});
}
