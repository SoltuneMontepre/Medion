using MediatR;
using Sale.Application.Common.DTOs;
using ServiceDefaults.ApiResponses;

namespace Sale.Application.Features.Product.Commands;

public class CreateProductCommand : IRequest<ApiResult<ProductDetailDto>>
{
    public CreateProductCommand()
    {
    }

    public CreateProductCommand(CreateProductDto dto)
    {
        Code = dto.Code;
        Name = dto.Name;
        Specification = dto.Specification;
        Type = dto.Type;
        Packaging = dto.Packaging;
    }

    public string Code { get; set; } = null!;
    public string Name { get; set; } = null!;
    public string Specification { get; set; } = null!;
    public string Type { get; set; } = null!;
    public string Packaging { get; set; } = null!;
}
