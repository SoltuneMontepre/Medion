using MediatR;
using Sale.Application.Common.DTOs;
using Sale.Domain.Identifiers;

namespace Sale.Application.Features.Order.Queries;

public sealed class GetTodayOrderByCustomerQuery(CustomerId customerId) : IRequest<OrderSummaryDto?>
{
  public CustomerId CustomerId { get; } = customerId;
}
