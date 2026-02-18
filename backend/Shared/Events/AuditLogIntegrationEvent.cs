using Medion.Shared.Enums;

namespace Medion.Shared.Events;

/// <summary>
///     Integration event published for audit logging.
/// </summary>
public record AuditLogIntegrationEvent
{
    public string EventId { get; set; } = Guid.NewGuid().ToString();
    public DateTime OccurredAt { get; set; } = DateTime.UtcNow;
    public string ServiceName { get; set; } = null!;
    public string UserId { get; set; } = null!;
    public string Action { get; set; } = null!;
    public string EntityType { get; set; } = null!;
    public string EntityId { get; set; } = null!;
    public string? Payload { get; set; }
    public string? SignatureHash { get; set; }
    public string IpAddress { get; set; } = null!;

    /// <summary>
    ///     HTTP status code of the operation (e.g., 200, 400, 500).
    /// </summary>
    public int? StatusCode { get; set; }

    /// <summary>
    ///     Error message if the action failed.
    /// </summary>
    public string? ErrorMessage { get; set; }

    /// <summary>
    ///     Trace identifier for distributed tracing across microservices.
    ///     Obtained from HttpContext.TraceIdentifier or OpenTelemetry headers.
    ///     Enables correlation of logs across Seq, Jaeger, and MongoDB.
    /// </summary>
    public string TraceId { get; set; } = null!;

    /// <summary>
    ///     Business status of the action (Success, Failed, Pending).
    ///     Simplifies dashboard filtering and reporting of success rates.
    /// </summary>
    public ActionStatus ActionStatus { get; set; }

    /// <summary>
    ///     Client information including browser, mobile app, or API client.
    ///     Captured from User-Agent header.
    ///     Critical for investigating security incidents and UI issues.
    /// </summary>
    public string? UserAgent { get; set; }
}
