import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/audit_log.dart';
import '../../domain/repositories/audit_repository.dart';
import '../datasources/audit_remote_datasource.dart';
import '../datasources/audit_remote_datasource_impl.dart';

class AuditRepositoryImpl implements AuditRepository {
  AuditRepositoryImpl(this._dataSource);

  final AuditRemoteDataSource _dataSource;

  @override
  Future<List<AuditLog>> getLogs({int page = 1, int pageSize = 20}) async {
    final models = await _dataSource.fetchLogs(page: page, pageSize: pageSize);
    return models.map((m) => m.toEntity()).toList();
  }
}

final auditRepositoryProvider = Provider<AuditRepository>((ref) {
  final dataSource = ref.watch(auditRemoteDataSourceProvider);
  return AuditRepositoryImpl(dataSource);
});
