using Grpc.Core;
using Sale.Application.Abstractions;
using Sale.Domain.Entities;
using Services.Sale.Contracts;
using OrderItem = Sale.Domain.Entities.OrderItem;

namespace Sale.API.Grpc;

public sealed class SaleService(IOrderRepository repo) : Services.Sale.Contracts.Sale.SaleBase
{
    public override async Task<OrderReply> GetOrder(GetOrderRequest request, ServerCallContext context)
    {
        var found = await repo.GetAsync(request.Id, context.CancellationToken);
        if (found is null)
            throw new RpcException(new Status(StatusCode.NotFound, "order not found"));

        return new OrderReply
        {
            Id = found.Id,
            Status = found.Status,
            Total = new Money { Currency = "USD", Amount = (double)found.Total }
        };
    }

    public override async Task<OrderReply> CreateOrder(CreateOrderRequest request, ServerCallContext context)
    {
        var items = request.Items
            .Select(i => new OrderItem(i.Sku, i.Quantity, (decimal)i.UnitPrice))
            .ToList();

        var order = new Order(Guid.NewGuid().ToString("N"), request.CustomerId)
        {
            Items = items
        };
        order.MarkSubmitted();

        var saved = await repo.AddAsync(order, context.CancellationToken);

        return new OrderReply
        {
            Id = saved.Id,
            Status = saved.Status,
            Total = new Money { Currency = "USD", Amount = (double)saved.Total }
        };
    }
}
