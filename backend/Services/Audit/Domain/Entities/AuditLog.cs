using Medion.Shared.Enums;
using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace Audit.Domain.Entities;

/// <summary>
///     MongoDB document representing an audit log entry
/// </summary>
[BsonIgnoreExtraElements]
public class AuditLog
{
    [BsonId]
    [BsonRepresentation(BsonType.ObjectId)]
    public ObjectId Id { get; set; }

    [BsonElement("eventId")]
    public string EventId { get; set; } = null!;

    [BsonElement("occurredAt")]
    public DateTime OccurredAt { get; set; }

    [BsonElement("serviceName")]
    public string ServiceName { get; set; } = null!;

    [BsonElement("userId")]
    public string UserId { get; set; } = null!;

    [BsonElement("action")]
    public string Action { get; set; } = null!;

    [BsonElement("entityType")]
    public string EntityType { get; set; } = null!;

    [BsonElement("entityId")]
    public string EntityId { get; set; } = null!;

    [BsonElement("payload")]
    public string? Payload { get; set; }

    [BsonElement("signatureHash")]
    public string? SignatureHash { get; set; }

    [BsonElement("ipAddress")]
    public string IpAddress { get; set; } = null!;

    [BsonElement("statusCode")]
    public int? StatusCode { get; set; }

    [BsonElement("errorMessage")]
    public string? ErrorMessage { get; set; }

    /// <summary>
    ///     Trace identifier for distributed tracing across microservices.
    ///     Obtained from HttpContext.TraceIdentifier or OpenTelemetry headers.
    ///     Enables correlation of logs across Seq, Jaeger, and MongoDB.
    /// </summary>
    [BsonElement("traceId")]
    public string TraceId { get; set; } = null!;

    /// <summary>
    ///     Business status of the action (Success, Failed, Pending).
    ///     Simplifies dashboard filtering and reporting of success rates.
    /// </summary>
    [BsonElement("actionStatus")]
    [BsonRepresentation(BsonType.String)]
    public ActionStatus ActionStatus { get; set; }

    /// <summary>
    ///     Client information including browser, mobile app, or API client.
    ///     Captured from User-Agent header.
    ///     Critical for investigating security incidents and UI issues.
    /// </summary>
    [BsonElement("userAgent")]
    public string? UserAgent { get; set; }

    [BsonElement("createdAt")]
    [BsonDateTimeOptions(Kind = DateTimeKind.Utc)]
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // TODO: Move factory method to Application layer mapper - Domain should not reference Application
    // Violates Clean Architecture: Domain → Application dependency
    /*
    /// <summary>
    ///     Factory method for creating audit log from integration event
    /// </summary>
    public static AuditLog FromIntegrationEvent(Audit.Application.Common.Events.AuditLogIntegrationEvent @event)
    {
      return new AuditLog
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
        ErrorMessage = @event.ErrorMessage
      };
    }
    */
}
