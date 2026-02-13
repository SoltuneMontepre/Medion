using Mapster;
using MediatR;
using Sale.Application.Common.DTOs;
using Sale.Domain.Repositories;

namespace Sale.Application.Features.Customer.Queries;

public sealed class SearchCustomersQueryHandler(ICustomerRepository customerRepository)
    : IRequestHandler<SearchCustomersQuery, IReadOnlyList<CustomerDto>>
{
  public async Task<IReadOnlyList<CustomerDto>> Handle(SearchCustomersQuery request, CancellationToken cancellationToken)
  {
    var customers = await customerRepository.SearchAsync(request.Term, request.Limit, cancellationToken);
    return customers.Adapt<IReadOnlyList<CustomerDto>>();
  }
}
