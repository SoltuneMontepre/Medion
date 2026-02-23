using Sale.Application.Common.Attributes;
using Sale.Application.Common.DTOs;
using Sale.Domain.Identifiers;
using Sale.Domain.Identifiers.Id;
using ServiceDefaults.ApiResponses;

namespace Sale.Application.Features.Order.Commands;

public class UpdateOrderCommand : IRequest<ApiResult<OrderDto>>, IRequireDigitalSignature
{
    public UpdateOrderCommand()
    {
    }

    public UpdateOrderCommand(OrderId orderId, UpdateOrderDto dto, UserId salesStaffId)
    {
        OrderId = orderId;
        SalesStaffId = salesStaffId;
        Items = dto.Items ?? [];
    }

    public OrderId OrderId { get; set; }
    public UserId SalesStaffId { get; set; }
    public IReadOnlyCollection<CreateOrderItemDto> Items { get; set; } = [];
}
