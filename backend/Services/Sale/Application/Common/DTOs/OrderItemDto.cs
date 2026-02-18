using Sale.Domain.Identifiers.Id;

namespace Sale.Application.Common.DTOs;

public class OrderItemDto
{
    public OrderItemId Id { get; set; }
    public ProductId ProductId { get; set; }
    public string ProductCode { get; set; } = null!;
    public string ProductName { get; set; } = null!;
    public int Quantity { get; set; }
}
