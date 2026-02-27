import '../models/approval_request_model.dart';

/// DataSource talks to API. Uses Dio from core/network via injector.
abstract class ApprovalRemoteDataSource {
  Future<List<ApprovalRequestModel>> fetchRequests({int page = 1, int pageSize = 20});
}
