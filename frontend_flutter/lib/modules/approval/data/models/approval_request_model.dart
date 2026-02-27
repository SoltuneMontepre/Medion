import '../../domain/entities/approval_request.dart';

/// Data model with fromJson. Maps to domain entity.
class ApprovalRequestModel {
  const ApprovalRequestModel({
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

  factory ApprovalRequestModel.fromJson(Map<String, dynamic> json) {
    return ApprovalRequestModel(
      id: json['id'] as String? ?? '',
      requestType: json['requestType'] as String? ?? '',
      requester: json['requester'] as String? ?? '',
      status: json['status'] as String? ?? '',
      date: json['date'] as String? ?? '',
    );
  }

  ApprovalRequest toEntity() => ApprovalRequest(
        id: id,
        requestType: requestType,
        requester: requester,
        status: status,
        date: date,
      );
}
