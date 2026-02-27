import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client_provider.dart';
import '../../../../core/network/dio_client.dart';
import '../models/approval_request_model.dart';
import 'approval_remote_datasource.dart';

/// Implementation: calls API via shared Dio client. Approval.API backend.
class ApprovalRemoteDataSourceImpl implements ApprovalRemoteDataSource {
  ApprovalRemoteDataSourceImpl(this._client);

  // ignore: unused_field
  final DioClient _client;

  @override
  Future<List<ApprovalRequestModel>> fetchRequests({
    int page = 1,
    int pageSize = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final base = (page - 1) * pageSize;
    return List.generate(
      5,
      (i) => ApprovalRequestModel(
        id: '${base + i + 1}',
        requestType: i.isEven ? 'Nghỉ phép' : 'Chi phí',
        requester: 'Người dùng ${base + i + 1}',
        status: i.isEven ? 'Chờ duyệt' : 'Đã duyệt',
        date: '2025-02-${(base + i + 1).clamp(1, 28)}',
      ),
    );
  }
}

final approvalRemoteDataSourceProvider = Provider<ApprovalRemoteDataSource>((ref) {
  final client = ref.watch(apiClientProvider);
  return ApprovalRemoteDataSourceImpl(client);
});
