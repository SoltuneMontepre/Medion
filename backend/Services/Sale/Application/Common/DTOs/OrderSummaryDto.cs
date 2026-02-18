using Sale.Domain.Entities;
using Sale.Domain.Identifiers.Id;

namespace Sale.Application.Common.DTOs;

public class OrderSummaryDto
{
    public OrderId Id { get; set; }
    public string OrderNumber { get; set; } = null!;
    public DateTime OrderDate { get; set; }
    public OrderStatus Status { get; set; }
    public CustomerId CustomerId { get; set; }
}
