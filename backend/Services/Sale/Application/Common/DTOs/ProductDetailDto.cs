using Sale.Domain.Identifiers;
using Sale.Domain.Identifiers.Id;

namespace Sale.Application.Common.DTOs;

public class ProductDetailDto
{
    public ProductId Id { get; set; }
    public string Code { get; set; } = null!;
    public string Name { get; set; } = null!;
    public string Specification { get; set; } = null!;
    public string Type { get; set; } = null!;
    public string Packaging { get; set; } = null!;
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
    public UserId? CreatedBy { get; set; }
    public UserId? UpdatedBy { get; set; }
}
