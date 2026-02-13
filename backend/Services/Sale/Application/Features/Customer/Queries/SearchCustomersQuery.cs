using MediatR;
using Sale.Application.Common.DTOs;

namespace Sale.Application.Features.Customer.Queries;

public sealed class SearchCustomersQuery(string term, int limit) : IRequest<IReadOnlyList<CustomerDto>>
{
  public string Term { get; } = term;
  public int Limit { get; } = limit;
}
