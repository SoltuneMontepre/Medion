using Mapster;
using MediatR;
using Sale.Application.Abstractions;
using Sale.Application.Common.DTOs;

namespace Sale.Application.Features.Product.Queries;

public sealed class SearchProductsQueryHandler(IProductRepository productRepository)
    : IRequestHandler<SearchProductsQuery, IReadOnlyList<ProductDto>>
{
  public async Task<IReadOnlyList<ProductDto>> Handle(SearchProductsQuery request, CancellationToken cancellationToken)
  {
    var products = await productRepository.SearchAsync(request.Term, request.Limit, cancellationToken);
    return products.Adapt<IReadOnlyList<ProductDto>>();
  }
}
