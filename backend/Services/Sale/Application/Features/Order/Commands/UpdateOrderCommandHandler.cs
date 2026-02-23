using Sale.Application.Abstractions;
using Sale.Application.Common.DTOs;
using Sale.Domain.Entities;
using ServiceDefaults.ApiResponses;

namespace Sale.Application.Features.Order.Commands;

public class UpdateOrderCommandHandler(
        IOrderRepository orderRepository,
        IProductRepository productRepository)
    : IRequestHandler<UpdateOrderCommand, ApiResult<OrderDto>>
{
    public async Task<ApiResult<OrderDto>> Handle(UpdateOrderCommand request, CancellationToken cancellationToken)
    {
        var order = await orderRepository.GetByIdAsync(request.OrderId, cancellationToken);
        if (order == null)
            return ApiResult<OrderDto>.NotFound("Order not found");

        var productIds = request.Items.Select(i => i.ProductId).Distinct().ToArray();
        var products = await productRepository.GetByIdsAsync(productIds, cancellationToken);
        var productLookup = products.ToDictionary(p => p.Id, p => p);

        var missingProductIds = productIds.Where(id => !productLookup.ContainsKey(id)).ToArray();
        if (missingProductIds.Length != 0)
        {
            var errors = new Dictionary<string, string[]>
            {
                { "MissingProducts", missingProductIds.Select(id => id.ToString()).ToArray() }
            };

            return ApiResult<OrderDto>.Failure("One or more products were not found", 400, errors);
        }

        foreach (var item in request.Items)
        {
            var product = productLookup[item.ProductId];
            var orderItem = new OrderItem();
            orderItem.Initialize(order.Id, item.ProductId, product.Code, product.Name, item.Quantity);
            orderItem.CreatedAt = DateTime.UtcNow;
            orderItem.CreatedBy = request.SalesStaffId;
            order.AddItem(orderItem);
        }

        order.UpdatedAt = DateTime.UtcNow;
        order.UpdatedBy = request.SalesStaffId;

        await orderRepository.UpdateOrderWithNewItemsAsync(order, cancellationToken);

        var dto = order.Adapt<OrderDto>();
        dto.Items = order.Items.Adapt<IReadOnlyCollection<OrderItemDto>>();
        return ApiResult<OrderDto>.Success(dto, "Order updated successfully");
    }
}
