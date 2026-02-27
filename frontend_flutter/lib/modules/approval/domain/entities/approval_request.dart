/// Domain entity. No Flutter, no JSON.
/// Corresponds to Approval.API backend.
class ApprovalRequest {
  const ApprovalRequest({
    required this.id,
    required this.requestType,
    required this.requester,
    required this.status,
    required this.date,
  });

  final String id;
  final String requestType;
  final String requester;
  final String status;
  final String date;
}
