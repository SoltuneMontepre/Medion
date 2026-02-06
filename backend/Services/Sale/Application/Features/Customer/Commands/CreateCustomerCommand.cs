using MediatR;
using Sale.Application.Common.DTOs;
using ServiceDefaults.ApiResponses;

namespace Sale.Application.Features.Customer.Commands;

/// <summary>
///     Command to create a new customer
/// </summary>
public class CreateCustomerCommand : IRequest<ApiResult<CustomerDto>>
{
    public CreateCustomerCommand()
    {
    }

    public CreateCustomerCommand(CreateCustomerDto dto)
    {
        FirstName = dto.FirstName;
        LastName = dto.LastName;
        Address = dto.Address;
        PhoneNumber = dto.PhoneNumber;
    }

    public string FirstName { get; set; } = null!;
    public string LastName { get; set; } = null!;
    public string Address { get; set; } = null!;
    public string PhoneNumber { get; set; } = null!;
}
