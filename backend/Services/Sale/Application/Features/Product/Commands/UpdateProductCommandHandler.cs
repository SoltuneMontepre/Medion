using Mapster;
using MediatR;
using Sale.Application.Common.DTOs;
using Sale.Domain.Repositories;
using ServiceDefaults.ApiResponses;

namespace Sale.Application.Features.Product.Commands;

public class UpdateProductCommandHandler(IProductRepository productRepository)
    : IRequestHandler<UpdateProductCommand, ApiResult<ProductDetailDto>>
{
  public async Task<ApiResult<ProductDetailDto>> Handle(UpdateProductCommand request,
      CancellationToken cancellationToken)
  {
    var product = await productRepository.GetByIdAsync(request.Id, cancellationToken);
    if (product == null)
      return ApiResult<ProductDetailDto>.NotFound("Product not found");

    var exists = await productRepository.ExistsByCodeAsync(request.Code, request.Id, cancellationToken);
    if (exists)
      return ApiResult<ProductDetailDto>.Failure("Product code already exists", 409);

    product.Code = request.Code;
    product.Name = request.Name;
    product.Specification = request.Specification;
    product.Type = request.Type;
    product.Packaging = request.Packaging;

    await productRepository.UpdateAsync(product, cancellationToken);

    var dto = product.Adapt<ProductDetailDto>();
    return ApiResult<ProductDetailDto>.Success(dto, "Product updated successfully");
  }
}
