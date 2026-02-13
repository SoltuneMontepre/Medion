using MediatR;
using Sale.Application.Common.DTOs;
using Sale.Domain.Identifiers.Id;

namespace Sale.Application.Features.Product.Queries;

public class GetProductByIdQuery(ProductId productId) : IRequest<ProductDetailDto?>
{
  public ProductId ProductId { get; } = productId;
}
