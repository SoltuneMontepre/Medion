using Sale.Domain.Identifiers;
using Sale.Domain.Identifiers.Id;

namespace Sale.Application.Common.DTOs;

public class CreateOrderDto
{
    public CustomerId CustomerId { get; set; }
    public UserId SalesStaffId { get; set; }
    public string Pin { get; set; } = null!;
    public IReadOnlyCollection<CreateOrderItemDto> Items { get; set; } = [];
}
