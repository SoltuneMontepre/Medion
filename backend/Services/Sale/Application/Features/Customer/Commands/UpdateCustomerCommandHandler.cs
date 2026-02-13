using Mapster;
using MediatR;
using Sale.Application.Abstractions;
using Sale.Application.Common.DTOs;
using ServiceDefaults.ApiResponses;

namespace Sale.Application.Features.Customer.Commands;

/// <summary>
///     Handler for UpdateCustomerCommand
/// </summary>
public class UpdateCustomerCommandHandler(ICustomerRepository customerRepository)
    : IRequestHandler<UpdateCustomerCommand, ApiResult<CustomerDto>>
{
    public async Task<ApiResult<CustomerDto>> Handle(UpdateCustomerCommand request, CancellationToken cancellationToken)
    {
        // Get existing customer
        var customer = await customerRepository.GetByIdAsync(request.Id, cancellationToken);
        if (customer == null)
            return ApiResult<CustomerDto>.NotFound($"Customer with ID '{request.Id}' not found");

        // Update properties
        customer.FirstName = request.FirstName;
        customer.LastName = request.LastName;
        customer.Address = request.Address;
        customer.PhoneNumber = request.PhoneNumber;

        // Save changes
        await customerRepository.UpdateAsync(customer, cancellationToken);

        // Map to DTO and return
        var customerDto = customer.Adapt<CustomerDto>();
        return ApiResult<CustomerDto>.Success(customerDto, "Customer updated successfully");
    }
}
