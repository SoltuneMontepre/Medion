using Mapster;
using MediatR;
using Sale.Application.Abstractions;
using Sale.Application.Common.DTOs;

namespace Sale.Application.Features.Product.Queries;

public class GetProductByIdQueryHandler(IProductRepository productRepository)
    : IRequestHandler<GetProductByIdQuery, ProductDetailDto?>
{
  public async Task<ProductDetailDto?> Handle(GetProductByIdQuery request, CancellationToken cancellationToken)
  {
    var product = await productRepository.GetByIdAsync(request.ProductId, cancellationToken);
    return product?.Adapt<ProductDetailDto>();
  }
}
