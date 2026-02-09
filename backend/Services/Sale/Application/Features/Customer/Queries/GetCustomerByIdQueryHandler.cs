using Mapster;
using MediatR;
using Sale.Application.Common.DTOs;
using Sale.Domain.Repositories;

namespace Sale.Application.Features.Customer.Queries;

/// <summary>
///     Handler for GetCustomerByIdQuery
/// </summary>
public class GetCustomerByIdQueryHandler(ICustomerRepository customerRepository)
    : IRequestHandler<GetCustomerByIdQuery, CustomerDto?>
{
    public async Task<CustomerDto?> Handle(GetCustomerByIdQuery request, CancellationToken cancellationToken)
    {
        var customer = await customerRepository.GetByIdAsync(request.CustomerId, cancellationToken);
        return customer?.Adapt<CustomerDto>();
    }
}
