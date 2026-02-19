using MediatR;
using Sale.Application.Common.DTOs;
using Sale.Domain.Identifiers.Id;

namespace Sale.Application.Features.Order.Queries;

public sealed class GetTodayOrderByCustomerQuery(CustomerId customerId) : IRequest<OrderSummaryDto?>
{
    public CustomerId CustomerId { get; } = customerId;
}
