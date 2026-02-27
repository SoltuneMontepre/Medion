import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/audit_log.dart';
import '../../domain/usecases/get_audit_logs.dart';
import '../../data/repositories_impl/audit_repository_impl.dart';

/// Async state: loading/error/data. Scoped per module.
final auditLogsProvider =
    FutureProvider.autoDispose.family<List<AuditLog>, int>((ref, page) {
  final repository = ref.watch(auditRepositoryProvider);
  final useCase = GetAuditLogs(repository);
  return useCase(page: page, pageSize: 20);
});
