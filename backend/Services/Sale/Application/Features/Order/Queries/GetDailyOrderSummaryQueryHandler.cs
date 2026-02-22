using MediatR;
using Sale.Application.Abstractions;
using Sale.Application.Common.DTOs;
using Sale.Domain.Identifiers.Id;

namespace Sale.Application.Features.Order.Queries;

/// <summary>
///     Aggregates all orders for the given date by product and returns summary rows for the daily report table.
/// </summary>
public sealed class GetDailyOrderSummaryQueryHandler(
    IOrderRepository orderRepository,
    IProductRepository productRepository)
    : IRequestHandler<GetDailyOrderSummaryQuery, IReadOnlyList<DailyOrderSummaryItemDto>>
{
    public async Task<IReadOnlyList<DailyOrderSummaryItemDto>> Handle(GetDailyOrderSummaryQuery request,
        CancellationToken cancellationToken)
    {
        var orders = await orderRepository.GetOrdersByDateAsync(request.Date, cancellationToken);
        if (orders.Count == 0)
            return Array.Empty<DailyOrderSummaryItemDto>();

        // Flatten all order items and group by ProductId, sum Quantity
        var aggregated = orders
            .SelectMany(o => o.Items)
            .GroupBy(i => i.ProductId)
            .Select(g => new { ProductId = g.Key, TotalQuantity = g.Sum(i => i.Quantity), FirstItem = g.First() })
            .ToList();

        if (aggregated.Count == 0)
            return Array.Empty<DailyOrderSummaryItemDto>();

        var productIds = aggregated.Select(a => a.ProductId).Distinct().ToArray();
        var products = await productRepository.GetByIdsAsync(productIds, cancellationToken);
        var productMap = products.ToDictionary(p => p.Id, p => p);

        var result = new List<DailyOrderSummaryItemDto>();
        var stt = 1;
        foreach (var item in aggregated.OrderBy(a => a.FirstItem.ProductCode))
        {
            var product = productMap.GetValueOrDefault(item.ProductId);
            result.Add(new DailyOrderSummaryItemDto
            {
                Stt = stt++,
                ProductCode = item.FirstItem.ProductCode,
                ProductName = item.FirstItem.ProductName,
                Specification = product?.Specification ?? "",
                Form = product?.Type ?? "",
                Packaging = product?.Packaging ?? "",
                TotalQuantity = item.TotalQuantity
            });
        }

        return result;
    }
}
