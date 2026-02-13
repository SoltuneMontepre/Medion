using Mapster;
using MediatR;
using Sale.Application.Abstractions;
using Sale.Application.Common.DTOs;
using Sale.Domain.Entities;
using ServiceDefaults.ApiResponses;

namespace Sale.Application.Features.Product.Commands;

public class CreateProductCommandHandler(IProductRepository productRepository)
    : IRequestHandler<CreateProductCommand, ApiResult<ProductDetailDto>>
{
  public async Task<ApiResult<ProductDetailDto>> Handle(CreateProductCommand request,
      CancellationToken cancellationToken)
  {
    var exists = await productRepository.ExistsByCodeAsync(request.Code, cancellationToken: cancellationToken);
    if (exists)
      return ApiResult<ProductDetailDto>.Failure("Product code already exists", 409);

    var product = request.Adapt<Domain.Entities.Product>();
    product.CreatedAt = DateTime.UtcNow;

    await productRepository.AddAsync(product, cancellationToken);

    var dto = product.Adapt<ProductDetailDto>();
    return ApiResult<ProductDetailDto>.Created(dto, "Product created successfully");
  }
}
