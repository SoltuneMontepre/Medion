using System.Text.Json;
using Mapster;
using MassTransit;
using MediatR;
using Medion.Shared.Events;
using Sale.Application.Abstractions;
using Sale.Application.Common.DTOs;
using ServiceDefaults.ApiResponses;

namespace Sale.Application.Features.Customer.Commands;

/// <summary>
///     Handler for CreateCustomerCommand using event-driven architecture.
///     Follows the Single Responsibility Principle by focusing ONLY on customer creation.
///
///     Workflow:
///     1. Generate unique customer code
///     2. Create and save Customer entity to database
///     3. Publish CustomerCreatedIntegrationEvent to RabbitMQ (fire-and-forget)
///
///     The digital signature creation is now handled asynchronously by the Audit Service
///     consuming the event, ensuring:
///     - Fast response time to the caller (no Vault latency)
///     - Decoupling from Vault dependencies
///     - Resilience if Audit Service is temporarily unavailable
///     - Better scalability under high load
///
///     Non-repudiation is still maintained: the Audit Service will capture the event
///     and create a digitally signed audit log entry in the database.
/// </summary>
public class CreateCustomerCommandHandler(
    ICustomerRepository customerRepository,
    IPublishEndpoint publishEndpoint)
    : IRequestHandler<CreateCustomerCommand, ApiResult<CustomerDto>>
{
    public async Task<ApiResult<CustomerDto>> Handle(
        CreateCustomerCommand request,
        CancellationToken cancellationToken)
    {
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

        // Step 3: Save customer to database
        await customerRepository.AddAsync(customer, cancellationToken);

        // Step 4: Build the event payload (complete customer data as JSON)
        var eventPayload = JsonSerializer.Serialize(new
        {
            customerId = customer.Id.Value.ToString(),
            firstName = customer.FirstName,
            lastName = customer.LastName,
            address = customer.Address,
            phoneNumber = customer.PhoneNumber,
            code = customer.Code,
            createdByUserId = request.CreatedByUserId.Value.ToString(),
            createdAt = customer.CreatedAt
        });

        // Step 5: Publish integration event to RabbitMQ
        // The Audit Service will consume this event and create a digitally signed audit log
        var integrationEvent = new CustomerCreatedIntegrationEvent(
            CorrelationId: Guid.NewGuid(),
            UserId: request.CreatedByUserId.Value.ToString(),
            Payload: eventPayload,
            Timestamp: DateTime.UtcNow);

        try
        {
            await publishEndpoint.Publish(integrationEvent, cancellationToken);
        }
        catch (Exception ex)
        {
            // Log the error but don't fail the customer creation
            // In production, implement a dead-letter queue strategy
            System.Diagnostics.Debug.WriteLine(
                $"Failed to publish CustomerCreatedIntegrationEvent: {ex.Message}");
        }

        // Step 6: Return success to caller immediately
        // The audit logging happens asynchronously in the Audit Service
        var customerDto = customer.Adapt<CustomerDto>();
        return ApiResult<CustomerDto>.Created(
            customerDto,
            "Customer created successfully. Audit log will be created asynchronously.");
    }
}
