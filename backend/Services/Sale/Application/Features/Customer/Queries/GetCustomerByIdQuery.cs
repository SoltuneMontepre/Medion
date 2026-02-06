using MediatR;
using Sale.Application.Common.DTOs;

namespace Sale.Application.Features.Customer.Queries;

/// <summary>
///     Query to get customer by ID
/// </summary>
public class GetCustomerByIdQuery(Guid customerId) : IRequest<CustomerDto?>
{
  public Guid CustomerId { get; set; } = customerId;
}
