using Sale.Domain.Abstractions;
using Sale.Domain.Identifiers.Id;

namespace Sale.Domain.Entities;

public sealed class Product : BaseEntity<ProductId>
{
    public Product()
    {
        Id = ProductId.New();
    }

    public string Code { get; set; } = null!;
    public string Name { get; set; } = null!;
    public string Specification { get; set; } = null!;
    public string Type { get; set; } = null!;
    public string Packaging { get; set; } = null!;
}
