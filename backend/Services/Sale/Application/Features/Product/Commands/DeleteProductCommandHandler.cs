using MediatR;
using Sale.Domain.Repositories;
using ServiceDefaults.ApiResponses;

namespace Sale.Application.Features.Product.Commands;

public class DeleteProductCommandHandler(IProductRepository productRepository)
    : IRequestHandler<DeleteProductCommand, ApiResult<bool>>
{
  public async Task<ApiResult<bool>> Handle(DeleteProductCommand request, CancellationToken cancellationToken)
  {
    var deleted = await productRepository.DeleteAsync(request.Id, cancellationToken);
    if (!deleted)
      return ApiResult<bool>.NotFound("Product not found");

    return ApiResult<bool>.Success(true, "Product deleted successfully");
  }
}
