using MediatR;
using Sale.Application.Common.DTOs;
using Sale.Domain.Identifiers;
using ServiceDefaults.ApiResponses;

namespace Sale.Application.Features.Order.Commands;

public class CreateOrderCommand : IRequest<ApiResult<OrderDto>>
{
    public CreateOrderCommand()
    {
    }

    public CreateOrderCommand(CreateOrderDto dto)
    {
        CustomerId = dto.CustomerId;
        SalesStaffId = dto.SalesStaffId;
        Pin = dto.Pin;
        Items = dto.Items ?? [];
    }

    public CustomerId CustomerId { get; set; }
    public UserId SalesStaffId { get; set; }
    public string Pin { get; set; } = null!;
    public IReadOnlyCollection<CreateOrderItemDto> Items { get; set; } = [];
}
