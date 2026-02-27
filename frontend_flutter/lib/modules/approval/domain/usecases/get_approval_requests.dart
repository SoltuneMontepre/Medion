import '../entities/approval_request.dart';
import '../repositories/approval_repository.dart';

/// UseCase handles business logic. Presentation calls UseCases only.
class GetApprovalRequests {
  GetApprovalRequests(this._repository);

  final ApprovalRepository _repository;

  Future<List<ApprovalRequest>> call({int page = 1, int pageSize = 20}) {
    return _repository.getRequests(page: page, pageSize: pageSize);
  }
}
