using System.Text.Json;
using Mapster;
using MassTransit;
using MediatR;
using Medion.Shared.Enums;
using Medion.Shared.Events;
using Microsoft.Extensions.Logging;
using Sale.Application.Abstractions;
using Sale.Application.Common.DTOs;
using ServiceDefaults.ApiResponses;
using TransactionContext = Sale.Application.Common.Context.TransactionContext;

namespace Sale.Application.Features.Customer.Commands;

/// <summary>
///     Handler for CreateCustomerCommand - PURE APPLICATION LOGIC.
///     CLEAN ARCHITECTURE:
///     - This handler does NOT know about HttpContext or Infrastructure
///     - It injects TransactionContext to retrieve signature (Application layer)
///     - It publishes AuditLogIntegrationEvent which MassTransit Outbox will handle atomically
///     - Customer entity and audit event are persisted in SAME database transaction
///     ATOMICITY (MassTransit Outbox Pattern):
///     1. Add customer to DbContext (NOT saved yet)
///     2. Publish audit event via MassTransit (stored in Outbox table)
///     3. Call SaveChangesAsync ONCE - commits: Customer + OutboxState entry
///     4. MassTransit background worker picks up event and publishes to RabbitMQ
///     Result: Exactly-once delivery semantics. No data loss if service crashes.
/// </summary>
public class CreateCustomerCommandHandler(
    ICustomerRepository customerRepository,
    TransactionContext transactionContext,
    IPublishEndpoint publishEndpoint,
    ILogger<CreateCustomerCommandHandler> logger)
    : IRequestHandler<CreateCustomerCommand, ApiResult<CustomerDto>>
{
    public async Task<ApiResult<CustomerDto>> Handle(
        CreateCustomerCommand request,
        CancellationToken cancellationToken)
    {
        logger.LogInformation(
            "Creating customer: {FirstName} {LastName} by user {UserId}",
            request.FirstName,
            request.LastName,
            request.CreatedByUserId.Value);

        // ✅ CLEAN ARCHITECTURE: Retrieve signature from scoped context (not HttpContext)
        if (!transactionContext.HasValidSignature)
        {
            logger.LogWarning("No valid transaction signature found in context");
            throw new InvalidOperationException(
                "Transaction signature not found. Ensure TransactionSigningBehavior executed.");
        }

        // Step 1: Generate unique customer code
        var customerCode = await customerRepository.GenerateCustomerCodeAsync(cancellationToken);

        // Step 2: Create customer entity from command
        var dto = new CreateCustomerDto
        {
            FirstName = request.FirstName,
            LastName = request.LastName,
            Address = request.Address,
            PhoneNumber = request.PhoneNumber
        };

        var customer = dto.Adapt<Domain.Entities.Customer>();
        customer.Code = customerCode;
        customer.CreatedAt = DateTime.UtcNow;
        customer.CreatedBy = request.CreatedByUserId;
        customer.SignatureHash = transactionContext.SignatureHash; // ✅ Attach signature from context

        logger.LogInformation(
            "Customer entity prepared: {CustomerId} with signature: {Signature}",
            customer.Id.Value,
            customer.SignatureHash?[..16] + "...");

        // Step 4: Create audit log integration event
        // NOTE: TraceId and UserAgent are not available in this handler (no HttpContext access)
        // Consider using AuditLoggingBehavior instead for complete audit context
        var auditEvent = new AuditLogIntegrationEvent
        {
            EventId = Guid.NewGuid().ToString(),
            OccurredAt = DateTime.UtcNow,
            ServiceName = "Sale",
            UserId = request.CreatedByUserId.Value.ToString(),
            Action = "CREATE",
            EntityType = "CUSTOMER",
            EntityId = customer.Id.Value.ToString(),
            Payload = JsonSerializer.Serialize(new
            {
                customerId = customer.Id.Value.ToString(),
                firstName = customer.FirstName,
                lastName = customer.LastName,
                address = customer.Address,
                phoneNumber = customer.PhoneNumber,
                code = customer.Code,
                createdAt = customer.CreatedAt
            }),
            SignatureHash = transactionContext.SignatureHash,
            StatusCode = 201,
            TraceId = Guid.NewGuid().ToString(), // Placeholder - HttpContext not available here
            ActionStatus = ActionStatus.Success,
            UserAgent = null // Not available without HttpContext
        };

        // Step 3: Save customer to repository
        // The repository handles persistence
        await customerRepository.AddAsync(customer, cancellationToken);

        // Step 4: Publish audit event (fire-and-forget)
        // The event will be published asynchronously to RabbitMQ
        try
        {
            await publishEndpoint.Publish(auditEvent, cancellationToken);
            logger.LogInformation("Audit log event published for customer {CustomerId}", customer.Id.Value);
        }
        catch (Exception ex)
        {
            // Log but don't fail customer creation if audit event fails
            logger.LogWarning(ex, "Warning: Failed to publish audit event for customer {CustomerId}",
                customer.Id.Value);
        }

        // Step 5: Return success to caller
        var customerDto = customer.Adapt<CustomerDto>();
        return ApiResult<CustomerDto>.Created(
            customerDto,
            "Customer created successfully with digital signature.");
    }
}
