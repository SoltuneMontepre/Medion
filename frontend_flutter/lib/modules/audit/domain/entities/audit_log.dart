/// Domain entity. No Flutter, no JSON.
class AuditLog {
  const AuditLog({
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
}
