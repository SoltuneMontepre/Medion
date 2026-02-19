using Audit.Application.Abstractions;
using Audit.Domain.Entities;
using Audit.Domain.Identifiers;
using Audit.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace Audit.Infrastructure.Persistence.Repositories;

/// <summary>
///     Repository implementation for GlobalAuditLog entity.
///     Provides data access and persistence operations for audit log records.
/// </summary>
public class GlobalAuditLogRepository(AuditDbContext dbContext) : IGlobalAuditLogRepository
{
  public async Task AddAsync(GlobalAuditLog auditLog, CancellationToken cancellationToken = default)
  {
    if (auditLog == null)
      throw new ArgumentNullException(nameof(auditLog));

    await dbContext.GlobalAuditLogs.AddAsync(auditLog, cancellationToken);
    await dbContext.SaveChangesAsync(cancellationToken);
  }

  public async Task<GlobalAuditLog?> GetByIdAsync(
      GlobalAuditLogId id,
      CancellationToken cancellationToken = default)
  {
    return await dbContext.GlobalAuditLogs
        .FirstOrDefaultAsync(a => a.Id == id, cancellationToken);
  }

  public async Task<IEnumerable<GlobalAuditLog>> GetByCorrelationIdAsync(
      Guid correlationId,
      CancellationToken cancellationToken = default)
  {
    return await dbContext.GlobalAuditLogs
        .Where(a => a.CorrelationId == correlationId)
        .OrderByDescending(a => a.CreatedAt)
        .ToListAsync(cancellationToken);
  }

  public async Task<IEnumerable<GlobalAuditLog>> GetByUserIdAsync(
      string userId,
      CancellationToken cancellationToken = default)
  {
    if (string.IsNullOrWhiteSpace(userId))
      throw new ArgumentException("User ID cannot be null or empty.", nameof(userId));

    return await dbContext.GlobalAuditLogs
        .Where(a => a.UserId == userId)
        .OrderByDescending(a => a.ActionTimestamp)
        .ToListAsync(cancellationToken);
  }

  public async Task<IEnumerable<GlobalAuditLog>> GetByAggregateTypeAndActionAsync(
      string aggregateType,
      string action,
      CancellationToken cancellationToken = default)
  {
    if (string.IsNullOrWhiteSpace(aggregateType))
      throw new ArgumentException("Aggregate type cannot be null or empty.", nameof(aggregateType));

    if (string.IsNullOrWhiteSpace(action))
      throw new ArgumentException("Action cannot be null or empty.", nameof(action));

    return await dbContext.GlobalAuditLogs
        .Where(a => a.AggregateType == aggregateType && a.Action == action)
        .OrderByDescending(a => a.CreatedAt)
        .ToListAsync(cancellationToken);
  }

  public async Task<IEnumerable<GlobalAuditLog>> GetUnverifiedAsync(
      CancellationToken cancellationToken = default)
  {
    return await dbContext.GlobalAuditLogs
        .Where(a => !a.IsVerified)
        .OrderBy(a => a.CreatedAt)
        .ToListAsync(cancellationToken);
  }

  public async Task MarkAsVerifiedAsync(
      GlobalAuditLogId id,
      CancellationToken cancellationToken = default)
  {
    var auditLog = await GetByIdAsync(id, cancellationToken);
    if (auditLog != null)
    {
      auditLog.IsVerified = true;
      auditLog.VerifiedAt = DateTime.UtcNow;
      dbContext.GlobalAuditLogs.Update(auditLog);
      await dbContext.SaveChangesAsync(cancellationToken);
    }
  }
}
