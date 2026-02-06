using MediatR;
using Sale.Application.Common.DTOs;

namespace Sale.Application.Features.Customer.Queries;

/// <summary>
///     Query to get all customers
/// </summary>
public class GetAllCustomersQuery : IRequest<IEnumerable<CustomerDto>>
{
}
