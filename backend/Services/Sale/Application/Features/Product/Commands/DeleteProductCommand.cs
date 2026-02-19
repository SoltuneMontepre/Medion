using MediatR;
using Sale.Domain.Identifiers.Id;
using ServiceDefaults.ApiResponses;

namespace Sale.Application.Features.Product.Commands;

public class DeleteProductCommand(ProductId id) : IRequest<ApiResult<bool>>
{
    public ProductId Id { get; } = id;
}
