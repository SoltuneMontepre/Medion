using Sale.Domain.Identifiers;

namespace Sale.Application.Common.DTOs;

public class CreateOrderDto
{
    public CustomerId CustomerId { get; set; }
    public UserId SalesStaffId { get; set; }
    public string Pin { get; set; } = null!;
    public IReadOnlyCollection<CreateOrderItemDto> Items { get; set; } = [];
}
