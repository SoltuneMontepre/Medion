using MediatR;
using Sale.Application.Common.DTOs;

namespace Sale.Application.Features.Product.Queries;

public sealed class SearchProductsQuery(string term, int limit) : IRequest<IReadOnlyList<ProductDto>>
{
    public string Term { get; } = term;
    public int Limit { get; } = limit;
}
