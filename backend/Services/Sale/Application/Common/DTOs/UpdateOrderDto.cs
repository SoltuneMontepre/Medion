namespace Sale.Application.Common.DTOs;

public class UpdateOrderDto
{
    public IReadOnlyCollection<CreateOrderItemDto> Items { get; set; } = [];
}
