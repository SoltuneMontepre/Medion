import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client_provider.dart';
import '../../../../core/network/dio_client.dart';
import '../models/audit_log_model.dart';
import 'audit_remote_datasource.dart';

/// Implementation: calls API via shared Dio client.
class AuditRemoteDataSourceImpl implements AuditRemoteDataSource {
  AuditRemoteDataSourceImpl(this._client);

  // ignore: unused_field
  final DioClient _client;

  @override
  Future<List<AuditLogModel>> fetchLogs({
    int page = 1,
    int pageSize = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final base = (page - 1) * pageSize;
    return List.generate(
      5,
      (i) => AuditLogModel(
        id: '${base + i + 1}',
        action: i.isEven ? 'Tạo' : 'Cập nhật',
        userId: 'user-${(base + i + 1) % 3}',
        timestamp: '2025-02-26T${10 + i}:00:00Z',
        entityType: i.isEven ? 'Đơn hàng' : 'Kho',
        entityId: '${base + i + 1}',
      ),
    );
  }
}

final auditRemoteDataSourceProvider = Provider<AuditRemoteDataSource>((ref) {
  final client = ref.watch(apiClientProvider);
  return AuditRemoteDataSourceImpl(client);
});
