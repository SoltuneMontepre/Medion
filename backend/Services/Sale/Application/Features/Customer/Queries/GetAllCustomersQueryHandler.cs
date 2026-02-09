using Mapster;
using MediatR;
using Sale.Application.Common.DTOs;
using Sale.Domain.Repositories;

namespace Sale.Application.Features.Customer.Queries;

/// <summary>
///     Handler for GetAllCustomersQuery
/// </summary>
public class GetAllCustomersQueryHandler(ICustomerRepository customerRepository)
    : IRequestHandler<GetAllCustomersQuery, IEnumerable<CustomerDto>>
{
    public async Task<IEnumerable<CustomerDto>> Handle(GetAllCustomersQuery request, CancellationToken cancellationToken)
    {
        var customers = await customerRepository.GetAllAsync(cancellationToken);
        return customers.Adapt<IEnumerable<CustomerDto>>();
    }
}
