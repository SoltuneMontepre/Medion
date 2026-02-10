using MediatR;
using Sale.Application.Common.DTOs;
using Sale.Domain.Identifiers;

namespace Sale.Application.Features.Customer.Queries;

/// <summary>
///     Query to get customer by ID
/// </summary>
public class GetCustomerByIdQuery(CustomerId customerId) : IRequest<CustomerDto?>
{
    public CustomerId CustomerId { get; set; } = customerId;
}
