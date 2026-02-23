using Sale.Application.Common.DTOs;
using Sale.Domain.Identifiers.Id;

namespace Sale.Application.Features.Order.Queries;

public sealed class GetOrderByIdQuery(OrderId orderId) : IRequest<OrderDto?>
{
    public OrderId OrderId { get; } = orderId;
}
