using Mapster;
using MediatR;
using Sale.Application.Common.DTOs;
using Sale.Domain.Repositories;
using ServiceDefaults.ApiResponses;

namespace Sale.Application.Features.Customer.Commands;

/// <summary>
///     Handler for CreateCustomerCommand
/// </summary>
public class CreateCustomerCommandHandler(ICustomerRepository customerRepository)
    : IRequestHandler<CreateCustomerCommand, ApiResult<CustomerDto>>
{
    public async Task<ApiResult<CustomerDto>> Handle(CreateCustomerCommand request, CancellationToken cancellationToken)
    {
        // Generate unique customer code
        var customerCode = await customerRepository.GenerateCustomerCodeAsync(cancellationToken);

        var dto = new CreateCustomerDto
        {
            FirstName = request.FirstName,
            LastName = request.LastName,
            Address = request.Address,
            PhoneNumber = request.PhoneNumber
        };

        // Map from DTO to entity and set fields not handled by mapping
        var customer = dto.Adapt<Domain.Entities.Customer>();
        customer.Code = customerCode;
        customer.CreatedAt = DateTime.UtcNow;

        // Save to database
        await customerRepository.AddAsync(customer, cancellationToken);

        // Map to DTO and return
        var customerDto = customer.Adapt<CustomerDto>();
        return ApiResult<CustomerDto>.Created(customerDto, "Customer created successfully");
    }
}
