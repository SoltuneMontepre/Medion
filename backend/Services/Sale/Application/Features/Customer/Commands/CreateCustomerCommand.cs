using MediatR;
using Sale.Application.Common.DTOs;
using Sale.Domain.Identifiers;
using ServiceDefaults.ApiResponses;

namespace Sale.Application.Features.Customer.Commands;

/// <summary>
///     Command to create a new customer with digital signature support.
///     The CreatedByUserId is captured for non-repudiation, ensuring accountability
///     in customer creation operations.
/// </summary>
public class CreateCustomerCommand : IRequest<ApiResult<CustomerDto>>
{
    public CreateCustomerCommand()
    {
    }

    public CreateCustomerCommand(CreateCustomerDto dto, UserId createdByUserId)
    {
        FirstName = dto.FirstName;
        LastName = dto.LastName;
        Address = dto.Address;
        PhoneNumber = dto.PhoneNumber;
        CreatedByUserId = createdByUserId;
    }

    public string FirstName { get; set; } = null!;
    public string LastName { get; set; } = null!;
    public string Address { get; set; } = null!;
    public string PhoneNumber { get; set; } = null!;

    /// <summary>
    ///     The ID of the user creating the customer (for non-repudiation).
    /// </summary>
    public UserId CreatedByUserId { get; set; }
}
