using Audit.Application.Common.Events;
using Audit.Application.Common.Repositories;
using Audit.Domain.Entities;
using MassTransit;
using Microsoft.Extensions.Logging;

namespace Audit.Application.Features.AuditLog.EventHandlers;

/// <summary>
///     MassTransit Consumer for AuditLogIntegrationEvent
///     Listens to RabbitMQ and persists audit logs to MongoDB
/// </summary>
public class AuditLogIntegrationEventConsumer(
    IAuditLogRepository repository,
    ILogger<AuditLogIntegrationEventConsumer> logger)
    : IConsumer<AuditLogIntegrationEvent>
{
  public async Task Consume(ConsumeContext<AuditLogIntegrationEvent> context)
  {
    try
    {
      var @event = context.Message;

      logger.LogInformation(
          "Consuming audit log event {EventId}: {Action} on {EntityType} {EntityId} by user {UserId}",
          @event.EventId,
          @event.Action,
          @event.EntityType,
          @event.EntityId,
          @event.UserId);

      // Create domain entity from event (manual mapping - factory method removed from Domain layer)
      var auditLog = new Domain.Entities.AuditLog
      {
        EventId = @event.EventId,
        OccurredAt = @event.OccurredAt,
        ServiceName = @event.ServiceName,
        UserId = @event.UserId,
        Action = @event.Action,
        EntityType = @event.EntityType,
        EntityId = @event.EntityId,
        Payload = @event.Payload,
        SignatureHash = @event.SignatureHash,
        IpAddress = @event.IpAddress,
        StatusCode = @event.StatusCode,
        ErrorMessage = @event.ErrorMessage,
        CreatedAt = DateTime.UtcNow
      };

      // Persist to MongoDB
      await repository.InsertAsync(auditLog, context.CancellationToken);

      logger.LogInformation(
          "Audit log persisted to MongoDB. Event: {EventId}",
          @event.EventId);
    }
    catch (Exception ex)
    {
      logger.LogError(
          ex,
          "Error consuming audit log event {EventId}",
          context.Message.EventId);

      // Publish to error queue or re-throw to trigger retry
      throw;
    }
  }
}
