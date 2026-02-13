using Sale.Domain.Entities;
using Sale.Domain.Identifiers;
using Sale.Domain.Identifiers.Id;

namespace Sale.Domain.Repositories;

public interface IOrderRepository
{
  Task<Order?> GetByIdAsync(OrderId id, CancellationToken cancellationToken = default);
  Task<Order?> GetTodayOrderForCustomerAsync(CustomerId customerId, DateOnly date, CancellationToken cancellationToken = default);
  Task AddAsync(Order order, CancellationToken cancellationToken = default);
  Task<string> GenerateOrderNumberAsync(DateOnly date, CancellationToken cancellationToken = default);
}
