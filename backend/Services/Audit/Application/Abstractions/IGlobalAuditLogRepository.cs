using Audit.Domain.Entities;
using Audit.Domain.Identifiers;

namespace Audit.Application.Abstractions;

/// <summary>
///     Repository interface for managing GlobalAuditLog records.
///     Provides data access and query capabilities for audit trail operations.
/// </summary>
public interface IGlobalAuditLogRepository
{
  /// <summary>
  ///     Adds a new audit log entry to the database.
  /// </summary>
  /// <param name="auditLog">The audit log entity to save.</param>
  /// <param name="cancellationToken">Cancellation token for async operation.</param>
  Task AddAsync(GlobalAuditLog auditLog, CancellationToken cancellationToken = default);

  /// <summary>
  ///     Retrieves an audit log entry by its ID.
  /// </summary>
  /// <param name="id">The ID of the audit log to retrieve.</param>
  /// <param name="cancellationToken">Cancellation token for async operation.</param>
  /// <returns>The audit log if found; otherwise, null.</returns>
  Task<GlobalAuditLog?> GetByIdAsync(GlobalAuditLogId id, CancellationToken cancellationToken = default);

  /// <summary>
  ///     Retrieves all audit logs for a specific correlation ID.
  ///     Useful for tracing related events across multiple services.
  /// </summary>
  /// <param name="correlationId">The correlation ID to search for.</param>
  /// <param name="cancellationToken">Cancellation token for async operation.</param>
  /// <returns>A collection of audit logs with the specified correlation ID.</returns>
  Task<IEnumerable<GlobalAuditLog>> GetByCorrelationIdAsync(
      Guid correlationId,
      CancellationToken cancellationToken = default);

  /// <summary>
  ///     Retrieves all audit logs created by a specific user.
  ///     Useful for compliance reviews and user action tracking.
  /// </summary>
  /// <param name="userId">The ID of the user to search for.</param>
  /// <param name="cancellationToken">Cancellation token for async operation.</param>
  /// <returns>A collection of audit logs created by the specified user, ordered by timestamp.</returns>
  Task<IEnumerable<GlobalAuditLog>> GetByUserIdAsync(
      string userId,
      CancellationToken cancellationToken = default);

  /// <summary>
  ///     Retrieves all audit logs for a specific aggregate type and action.
  ///     Useful for filtering events by entity type and operation.
  /// </summary>
  /// <param name="aggregateType">The aggregate type (e.g., "Customer").</param>
  /// <param name="action">The action performed (e.g., "CREATE").</param>
  /// <param name="cancellationToken">Cancellation token for async operation.</param>
  /// <returns>A collection of matching audit logs ordered by timestamp.</returns>
  Task<IEnumerable<GlobalAuditLog>> GetByAggregateTypeAndActionAsync(
      string aggregateType,
      string action,
      CancellationToken cancellationToken = default);

  /// <summary>
  ///     Retrieves all unverified audit logs.
  ///     Useful for verification workflows and synchronization operations.
  /// </summary>
  /// <param name="cancellationToken">Cancellation token for async operation.</param>
  /// <returns>A collection of unverified audit logs.</returns>
  Task<IEnumerable<GlobalAuditLog>> GetUnverifiedAsync(CancellationToken cancellationToken = default);

  /// <summary>
  ///     Marks an audit log as verified.
  /// </summary>
  /// <param name="id">The ID of the audit log to mark as verified.</param>
  /// <param name="cancellationToken">Cancellation token for async operation.</param>
  Task MarkAsVerifiedAsync(GlobalAuditLogId id, CancellationToken cancellationToken = default);
}
