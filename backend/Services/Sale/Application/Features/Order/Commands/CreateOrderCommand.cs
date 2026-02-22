using MediatR;
using Sale.Application.Common.Attributes;
using Sale.Application.Common.DTOs;
using Sale.Domain.Identifiers;
using Sale.Domain.Identifiers.Id;
using ServiceDefaults.ApiResponses;

namespace Sale.Application.Features.Order.Commands;

public class CreateOrderCommand : IRequest<ApiResult<OrderDto>>, IRequireDigitalSignature
{
    public CreateOrderCommand()
    {
    }

    /// <summary>
    ///     Creates the command with salesStaffId from the authenticated user (JWT).
    /// </summary>
    public CreateOrderCommand(CreateOrderDto dto, UserId salesStaffId)
    {
        CustomerId = dto.CustomerId;
        SalesStaffId = salesStaffId;
        Items = dto.Items ?? [];
    }

    public CustomerId CustomerId { get; set; }
    public UserId SalesStaffId { get; set; }
    public IReadOnlyCollection<CreateOrderItemDto> Items { get; set; } = [];
}
