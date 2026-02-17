using Audit.Application.Abstractions;
using Audit.Domain.Entities;
using Audit.Domain.Identifiers;
using MassTransit;
using Medion.Shared.Events;
using Security.Application.Abstractions;

namespace Audit.Application.IntegrationEvents.Consumers;

/// <summary>
///     MassTransit consumer for the CustomerCreatedIntegrationEvent.
///     Responsible for creating digitally signed audit log entries when customers are created.
///
///     This consumer represents the "Audit Service" in the event-driven architecture.
///     It runs asynchronously, decoupled from the Sale Service, ensuring that:
///     1. Customer creation completes quickly (no Vault latency)
///     2. Audit logging is resilient and can retry on failure
///     3. Services remain loosely coupled via the message bus
///
///     Workflow:
///     1. Receive CustomerCreatedIntegrationEvent from RabbitMQ
///     2. Extract the customer payload from the event
///     3. Base64 encode the payload
///     4. Call IVaultDigitalSignatureService to sign the payload using Vault Transit Engine
///     5. Create GlobalAuditLog entity with the signature
///     6. Save to Audit database
///     7. Complete the message (acknowledge to RabbitMQ)
///
///     Error handling:
///     - If Vault signing fails: exception caught, message nacked, and retried by RabbitMQ
///     - If database save fails: exception caught, message nacked, and retried by RabbitMQ
///     - Dead-letter queue configured for messages that fail after max retries
/// </summary>
public class CustomerCreatedAuditConsumer(
    IGlobalAuditLogRepository auditLogRepository,
    IVaultDigitalSignatureService digitalSignatureService)
    : IConsumer<CustomerCreatedIntegrationEvent>
{
  public async Task Consume(ConsumeContext<CustomerCreatedIntegrationEvent> context)
  {
    var @event = context.Message;

    try
    {
      // Step 1: Extract the payload from the event
      if (string.IsNullOrWhiteSpace(@event.Payload))
        throw new ArgumentException("Event payload cannot be null or empty.");

      // Step 2: Base64 encode the payload for Vault Transit Engine
      var payloadBase64 = Convert.ToBase64String(
          System.Text.Encoding.UTF8.GetBytes(@event.Payload));

      // Step 3: Sign the payload using Vault Transit Engine
      var signature = await digitalSignatureService.SignDataAsync(
          payloadBase64,
          context.CancellationToken);

      // Step 4: Create the GlobalAuditLog entity
      var auditLog = new GlobalAuditLog
      {
        Id = GlobalAuditLogId.New(),
        CorrelationId = @event.CorrelationId,
        AggregateType = @event.AggregateType,
        Action = @event.Action,
        Payload = @event.Payload,
        UserId = @event.UserId,
        DigitalSignature = signature,
        ActionTimestamp = @event.Timestamp,
        CreatedAt = DateTime.UtcNow,
        IsVerified = false
      };

      // Step 5: Save to audit database
      await auditLogRepository.AddAsync(auditLog, context.CancellationToken);

      // Step 6: Complete the message (acknowledge to RabbitMQ)
      // If we reach here, everything succeeded and the message is consumed
    }
    catch (Exception ex)
    {
      // Log the error so operators can investigate
      System.Diagnostics.Debug.WriteLine(
          $"Failed to process CustomerCreatedIntegrationEvent (CorrelationId: {@event.CorrelationId}): {ex.Message}");

      // Throw the exception to trigger RabbitMQ retry/nack
      // MassTransit's retry policy will handle retries
      throw;
    }
  }
}
