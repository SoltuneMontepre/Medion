using Sale.Domain.Entities;
using Sale.Domain.Identifiers;
using Sale.Domain.Identifiers.Id;

namespace Sale.Application.Common.DTOs;

public class OrderDto
{
    public OrderId Id { get; set; }
    public string OrderNumber { get; set; } = null!;
    public CustomerId CustomerId { get; set; }
    public DateTime OrderDate { get; set; }
    public OrderStatus Status { get; set; }
    public UserId SalesStaffId { get; set; }
    public DateTime? SignedAt { get; set; }
    public UserId? SignedBy { get; set; }
    public string? SignaturePublicKey { get; set; }
    public IReadOnlyCollection<OrderItemDto> Items { get; set; } = [];
}
