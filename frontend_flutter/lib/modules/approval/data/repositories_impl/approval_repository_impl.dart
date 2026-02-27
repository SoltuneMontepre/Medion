import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/approval_request.dart';
import '../../domain/repositories/approval_repository.dart';
import '../datasources/approval_remote_datasource.dart';
import '../datasources/approval_remote_datasource_impl.dart';

class ApprovalRepositoryImpl implements ApprovalRepository {
  ApprovalRepositoryImpl(this._dataSource);

  final ApprovalRemoteDataSource _dataSource;

  @override
  Future<List<ApprovalRequest>> getRequests({int page = 1, int pageSize = 20}) async {
    final models = await _dataSource.fetchRequests(page: page, pageSize: pageSize);
    return models.map((m) => m.toEntity()).toList();
  }
}

final approvalRepositoryProvider = Provider<ApprovalRepository>((ref) {
  final dataSource = ref.watch(approvalRemoteDataSourceProvider);
  return ApprovalRepositoryImpl(dataSource);
});
