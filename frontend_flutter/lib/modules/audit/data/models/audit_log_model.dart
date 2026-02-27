import '../../domain/entities/audit_log.dart';

/// Data model with fromJson. Maps to domain entity.
class AuditLogModel {
  const AuditLogModel({
    required this.id,
    required this.action,
    required this.userId,
    required this.timestamp,
    required this.entityType,
    required this.entityId,
  });

  final String id;
  final String action;
  final String userId;
  final String timestamp;
  final String entityType;
  final String entityId;

  factory AuditLogModel.fromJson(Map<String, dynamic> json) {
    return AuditLogModel(
      id: json['id'] as String? ?? '',
      action: json['action'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      timestamp: json['timestamp'] as String? ?? '',
      entityType: json['entityType'] as String? ?? '',
      entityId: json['entityId'] as String? ?? '',
    );
  }

  AuditLog toEntity() => AuditLog(
        id: id,
        action: action,
        userId: userId,
        timestamp: timestamp,
        entityType: entityType,
        entityId: entityId,
      );
}
