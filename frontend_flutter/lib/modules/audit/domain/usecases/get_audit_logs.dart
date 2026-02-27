import '../entities/audit_log.dart';
import '../repositories/audit_repository.dart';

/// UseCase handles business logic. Presentation calls UseCases only.
class GetAuditLogs {
  GetAuditLogs(this._repository);

  final AuditRepository _repository;

  Future<List<AuditLog>> call({int page = 1, int pageSize = 20}) {
    return _repository.getLogs(page: page, pageSize: pageSize);
  }
}
