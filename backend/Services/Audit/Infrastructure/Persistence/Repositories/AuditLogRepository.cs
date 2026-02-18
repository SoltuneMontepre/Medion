using Audit.Application.Common.Repositories;
using Audit.Domain.Entities;
using MongoDB.Bson;
using MongoDB.Driver;

namespace Audit.Infrastructure.Persistence.Repositories;

public class AuditLogRepository(IMongoDatabase database) : IAuditLogRepository
{
  private readonly IMongoCollection<AuditLog> _collection = database.GetCollection<AuditLog>("audit_logs");

  public async Task InsertAsync(AuditLog auditLog, CancellationToken cancellationToken = default)
  {
    await _collection.InsertOneAsync(auditLog, cancellationToken: cancellationToken);
  }

  public async Task<IEnumerable<AuditLog>> GetByUserIdAsync(
      string userId,
      DateTime from,
      DateTime to,
      CancellationToken cancellationToken = default)
  {
    var filter = Builders<AuditLog>.Filter.And(
        Builders<AuditLog>.Filter.Eq(x => x.UserId, userId),
        Builders<AuditLog>.Filter.Gte(x => x.OccurredAt, from),
        Builders<AuditLog>.Filter.Lte(x => x.OccurredAt, to)
    );

    return await _collection
        .Find(filter)
        .SortByDescending(x => x.OccurredAt)
        .ToListAsync(cancellationToken);
  }

  public async Task<IEnumerable<AuditLog>> GetByEntityAsync(
      string entityType,
      string entityId,
      CancellationToken cancellationToken = default)
  {
    var filter = Builders<AuditLog>.Filter.And(
        Builders<AuditLog>.Filter.Eq(x => x.EntityType, entityType),
        Builders<AuditLog>.Filter.Eq(x => x.EntityId, entityId)
    );

    return await _collection
        .Find(filter)
        .SortByDescending(x => x.OccurredAt)
        .ToListAsync(cancellationToken);
  }
}
