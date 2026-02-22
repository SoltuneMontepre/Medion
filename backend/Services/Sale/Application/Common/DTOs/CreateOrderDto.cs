using Sale.Domain.Identifiers.Id;

namespace Sale.Application.Common.DTOs;

public class CreateOrderDto
{
    public CustomerId CustomerId { get; set; }
    public IReadOnlyCollection<CreateOrderItemDto> Items { get; set; } = [];
}
