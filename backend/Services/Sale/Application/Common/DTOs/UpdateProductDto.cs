namespace Sale.Application.Common.DTOs;

public class UpdateProductDto
{
    public string Code { get; set; } = null!;
    public string Name { get; set; } = null!;
    public string Specification { get; set; } = null!;
    public string Type { get; set; } = null!;
    public string Packaging { get; set; } = null!;
}
