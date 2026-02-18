using Sale.Domain.Identifiers.Id;

namespace Sale.Application.Common.DTOs;

public class CreateOrderItemDto
{
    public ProductId ProductId { get; set; }
    public int Quantity { get; set; }
}
