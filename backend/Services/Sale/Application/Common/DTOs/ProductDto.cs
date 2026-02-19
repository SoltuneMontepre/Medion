using Sale.Domain.Identifiers.Id;

namespace Sale.Application.Common.DTOs;

public class ProductDto
{
    public ProductId Id { get; set; }
    public string Code { get; set; } = null!;
    public string Name { get; set; } = null!;
}
