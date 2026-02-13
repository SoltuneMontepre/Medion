using Mapster;
using MediatR;
using Sale.Application.Common.DTOs;
using Sale.Domain.Repositories;

namespace Sale.Application.Features.Product.Queries;

public class GetAllProductsQueryHandler(IProductRepository productRepository)
    : IRequestHandler<GetAllProductsQuery, IReadOnlyList<ProductDto>>
{
  public async Task<IReadOnlyList<ProductDto>> Handle(GetAllProductsQuery request, CancellationToken cancellationToken)
  {
    var products = await productRepository.GetAllAsync(cancellationToken);
    return products.Adapt<IReadOnlyList<ProductDto>>();
  }
}
