namespace Audit.Application.Common.Events;

/// <summary>
///     Integration event contract (mirrors Sale.Application.Events.AuditLogIntegrationEvent)
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
  public int? StatusCode { get; set; }
  public string? ErrorMessage { get; set; }
}
