using Mapster;
using MediatR;
using Sale.Application.Abstractions;
using Sale.Application.Common.DTOs;

namespace Sale.Application.Features.Order.Queries;

public sealed class GetTodayOrderByCustomerQueryHandler(IOrderRepository orderRepository)
    : IRequestHandler<GetTodayOrderByCustomerQuery, OrderSummaryDto?>
{
    public async Task<OrderSummaryDto?> Handle(GetTodayOrderByCustomerQuery request,
        CancellationToken cancellationToken)
    {
        var today = DateOnly.FromDateTime(DateTime.UtcNow);
        var order = await orderRepository.GetTodayOrderForCustomerAsync(request.CustomerId, today, cancellationToken);
        return order?.Adapt<OrderSummaryDto>();
    }
}
