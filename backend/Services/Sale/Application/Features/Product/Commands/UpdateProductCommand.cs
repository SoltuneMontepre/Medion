using MediatR;
using Sale.Application.Common.DTOs;
using Sale.Domain.Identifiers.Id;
using ServiceDefaults.ApiResponses;

namespace Sale.Application.Features.Product.Commands;

public class UpdateProductCommand : IRequest<ApiResult<ProductDetailDto>>
{
    public ProductId Id { get; set; }
    public string Code { get; set; } = null!;
    public string Name { get; set; } = null!;
    public string Specification { get; set; } = null!;
    public string Type { get; set; } = null!;
    public string Packaging { get; set; } = null!;
}
