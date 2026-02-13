using Sale.Domain.Entities;
using Sale.Domain.Identifiers;
using Sale.Domain.Identifiers.Id;

namespace Sale.Application.Abstractions;

public interface IOrderRepository : IBaseRepository<Order, OrderId>
{
  Task<Order?> GetTodayOrderForCustomerAsync(CustomerId customerId, DateOnly date,
      CancellationToken cancellationToken = default);
  Task<string> GenerateOrderNumberAsync(DateOnly date, CancellationToken cancellationToken = default);
}
