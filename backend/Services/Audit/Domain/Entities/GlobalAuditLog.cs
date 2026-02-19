using Audit.Domain.Identifiers;

namespace Audit.Domain.Entities;

/// <summary>
///     GlobalAuditLog entity representing a single audit log entry with digital signature.
///     Provides comprehensive audit trail for compliance and non-repudiation across all services.
///
///     This entity stores:
///     - The aggregate type and action that was performed (e.g., "Customer" + "CREATE")
///     - The complete payload (JSON) of what was changed
///     - Who initiated the action and when
///     - A digital signature from Vault Transit Engine for non-repudiation
///
///     Together, these properties ensure accountability and tamper-evidence:
///     - WHO: UserId tracks the user who initiated the action
///     - WHAT: AggregateType + Action + Payload track the specific change
///     - WHEN: Timestamp records when it happened
///     - HOW: DigitalSignature proves it came from Vault (non-repudiation)
/// </summary>
public sealed class GlobalAuditLog
{
  /// <summary>
  ///     Unique identifier for this audit log entry.
  /// </summary>
  public GlobalAuditLogId Id { get; set; }

  /// <summary>
  ///     The correlation ID from the integration event.
  ///     Enables tracing of related events across multiple services and logs.
  /// </summary>
  public Guid CorrelationId { get; set; }

  /// <summary>
  ///     The type of aggregate being audited (e.g., "Customer", "Order", "Product").
  ///     Used for filtering and querying audit logs by entity type.
  /// </summary>
  public string AggregateType { get; set; } = null!;

  /// <summary>
  ///     The action performed on the aggregate (e.g., "CREATE", "UPDATE", "DELETE").
  ///     Combined with AggregateType to describe the operation.
  /// </summary>
  public string Action { get; set; } = null!;

  /// <summary>
  ///     The complete JSON payload of the data involved in this action.
  ///     Provides full context for audit trail and compliance review.
  /// </summary>
  public string Payload { get; set; } = null!;

  /// <summary>
  ///     The ID of the user who initiated this action.
  ///     Critical for non-repudiation and accountability tracking.
  /// </summary>
  public string UserId { get; set; } = null!;

  /// <summary>
  ///     The base64-encoded digital signature from Vault Transit Engine.
  ///     Format: "vault:v1:{base64-encoded-signature}"
  ///     Proves that this audit entry was created using the Vault signing key.
  /// </summary>
  public string DigitalSignature { get; set; } = null!;

  /// <summary>
  ///     The timestamp when the original action (in the source service) was performed.
  ///     Different from CreatedAt (below) which is when the audit log was created.
  /// </summary>
  public DateTime ActionTimestamp { get; set; }

  /// <summary>
  ///     The UTC timestamp when this audit log entry was created by the Audit Service.
  ///     Represents when the digital signature was generated.
  /// </summary>
  public DateTime CreatedAt { get; set; }

  /// <summary>
  ///     Indicates whether this audit entry has been verified against Vault.
  ///     Useful for audit trail verification and compliance checks.
  /// </summary>
  public bool IsVerified { get; set; }

  /// <summary>
  ///     The timestamp of the last verification operation, if any.
  /// </summary>
  public DateTime? VerifiedAt { get; set; }
}
