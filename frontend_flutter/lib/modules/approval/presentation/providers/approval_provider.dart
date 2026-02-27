import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/approval_request.dart';
import '../../domain/usecases/get_approval_requests.dart';
import '../../data/repositories_impl/approval_repository_impl.dart';

/// Async state: loading/error/data. Scoped per module.
final approvalRequestsProvider =
    FutureProvider.autoDispose.family<List<ApprovalRequest>, int>((ref, page) {
  final repository = ref.watch(approvalRepositoryProvider);
  final useCase = GetApprovalRequests(repository);
  return useCase(page: page, pageSize: 20);
});
