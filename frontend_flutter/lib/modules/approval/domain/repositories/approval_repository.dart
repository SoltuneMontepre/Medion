import '../entities/approval_request.dart';

/// Repository interface in domain. Implementation lives in data.
abstract class ApprovalRepository {
  Future<List<ApprovalRequest>> getRequests({int page = 1, int pageSize = 20});
}
