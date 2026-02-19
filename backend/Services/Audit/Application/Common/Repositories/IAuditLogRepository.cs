using Audit.Domain.Entities;

namespace Audit.Application.Common.Repositories;

public interface IAuditLogRepository
{
  Task InsertAsync(AuditLog auditLog, CancellationToken cancellationToken = default);

  Task<IEnumerable<AuditLog>> GetByUserIdAsync(
      string userId,
      DateTime from,
      DateTime to,
      CancellationToken cancellationToken = default);

  Task<IEnumerable<AuditLog>> GetByEntityAsync(
      string entityType,
      string entityId,
      CancellationToken cancellationToken = default);
}
