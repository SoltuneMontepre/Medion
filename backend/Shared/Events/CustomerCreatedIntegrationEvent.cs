namespace Medion.Shared.Events;

/// <summary>
///     Integration event published when a customer is created in the Sale Service.
///     This event is consumed by the Audit Service to create a digitally signed audit log entry.
///     Implements the Outbox/Inbox pattern for reliable event publishing and consumption.
/// </summary>
public sealed record CustomerCreatedIntegrationEvent(
    /// <summary>
    ///     Unique correlation identifier for tracing this event across services and logs.
    ///     Used for audit trail tracking and distributed tracing.
    /// </summary>
    Guid CorrelationId,

    /// <summary>
    ///     The ID of the user who initiated the customer creation.
    ///     Used for non-repudiation and audit accountability.
    /// </summary>
    string UserId,

    /// <summary>
    ///     The complete JSON payload of the customer data being created.
    ///     This is what will be signed by the Audit Service using Vault Transit Engine.
    ///     Format:
    ///     {
    ///       "customerId": "550e8400-e29b-41d4-a716-446655440000",
    ///       "firstName": "John",
    ///       "lastName": "Doe",
    ///       "address": "123 Main St",
    ///       "phoneNumber": "+1-555-0123",
    ///       "code": "CUS-2024-000001",
    ///       "createdByUserId": "660e8400-e29b-41d4-a716-446655440001",
    ///       "createdAt": "2024-02-17T10:30:00Z"
    ///     }
    /// </summary>
    string Payload,

    /// <summary>
    ///     The UTC timestamp when the event was published.
    ///     Represents the exact moment the customer was created in the Sale Service.
    /// </summary>
    DateTime Timestamp,

    /// <summary>
    ///     Friendly aggregate type for audit reporting. Always "Customer" for this event.
    /// </summary>
    string AggregateType = "Customer",

    /// <summary>
    ///     The action being performed. Always "CREATE" for this event.
    /// </summary>
    string Action = "CREATE")
{
  /// <summary>
  ///     Required for MassTransit message contract.
  ///     The timestamp property provides the event timestamp.
  /// </summary>
  public DateTime? Timestamp { get; } = Timestamp;
}
